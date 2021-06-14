import 'dart:io';

import 'package:dart_code_metrics/config.dart';
import 'package:dart_code_metrics/metrics_analyzer.dart';
import 'package:dart_code_metrics_github_action_app/action_app.dart';

Future<void> main(List<String> args) async {
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
    await reporting.run();

    workflowUtils.startLogGroup('Running Dart Code Metrics');

    final foldersToAnalyze = arguments.folders;
    final rootFolder = arguments.packagePath.canonicalPackagePath;
    final options = await analysisOptionsFromFilePath(rootFolder);
    final config = Config.fromAnalysisOptions(options);
    final lintConfig = ConfigBuilder.getLintConfig(config, rootFolder);

    final result = await const LintAnalyzer()
        .runCliAnalysis(foldersToAnalyze, rootFolder, lintConfig);

    await reporting.complete(result, pubspec(rootFolder).packageName);
  } on Exception catch (cause) {
    try {
      await reporting.cancel(cause: cause);
      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      workflowUtils.logErrorMessage('$error\n$stackTrace');
    }
  }
}
