import 'dart:io';

import 'package:action_app/action_app.dart';
import 'package:dart_code_metrics/config.dart';
import 'package:dart_code_metrics/lint_analyzer.dart';

Future<void> main() async {
  final workflowUtils = GitHubWorkflowUtils(
    environmentVariables: Platform.environment,
    output: stdout,
  );

  final arguments = Arguments(workflowUtils);
  final reporting = await Reporter.create(
    workflowUtils: workflowUtils,
    arguments: arguments,
  );

  try {
    final rootFolder = arguments.packagePath.canonicalPackagePath;
    final pubspec = readPubspec(rootFolder);

    workflowUtils.startLogGroup("Get the current package's dependencies");

    final executable = pubspec.isFlutterPackage ? 'flutter' : 'dart';
    final pubGetResult = Process.runSync(executable, ['pub', 'get']);
    stdout.writeln(pubGetResult.stdout);
    stderr.writeln(pubGetResult.stderr);

    workflowUtils.endLogGroup();

    await reporting.run();

    workflowUtils.startLogGroup('Running Dart Code Metrics');

    final foldersToAnalyze = arguments.folders;
    final options = await analysisOptionsFromFilePath(rootFolder);
    final config = Config.fromAnalysisOptions(options);
    final lintConfig = ConfigBuilder.getLintConfig(config, rootFolder);

    final lintAnalyzerReport = await const LintAnalyzer()
        .runCliAnalysis(foldersToAnalyze, rootFolder, lintConfig);

    await reporting.complete(
      pubspec.packageName,
      foldersToAnalyze,
      lintAnalyzerReport,
    );

    workflowUtils.endLogGroup();
  } on Exception catch (cause) {
    try {
      await reporting.cancel(cause: cause);
      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      workflowUtils.logErrorMessage('$error\n$stackTrace');
    }
  }
}
