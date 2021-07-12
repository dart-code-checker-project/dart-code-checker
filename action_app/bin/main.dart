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

  if (arguments.gitHubPersonalAccessTokenKey.isNotEmpty) {
    gitHubAuthSetup(arguments.gitHubPersonalAccessTokenKey, workflowUtils);
  }

  try {
    final rootFolder = arguments.packagePath.canonicalPackagePath;
    final pubspecUtils = readPubspec(rootFolder);

    _getTheTargetPackagesDependencies(workflowUtils, pubspecUtils, rootFolder);

    await reporting.run();

    workflowUtils.startLogGroup('Running Dart Code Metrics');

    final foldersToAnalyze = arguments.folders;
    final options = await analysisOptionsFromFilePath(rootFolder);
    final config = LintConfig.fromAnalysisOptions(options);

    final lintAnalyzerReport = await const LintAnalyzer()
        .runCliAnalysis(foldersToAnalyze, rootFolder, config);

    await reporting.complete(
      pubspecUtils.packageName,
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

void _getTheTargetPackagesDependencies(
  GitHubWorkflowUtils workflowUtils,
  PubSpecUtils pubSpecUtils,
  String rootFolder,
) {
  workflowUtils.startLogGroup(
    'Get the "${pubSpecUtils.packageName}" package dependencies',
  );

  final executable = pubSpecUtils.isFlutterPackage ? 'flutter' : 'dart';
  final pubGetResult = Process.runSync(
    executable,
    ['pub', 'get'],
    workingDirectory: rootFolder,
  );
  workflowUtils
    ..logDebugMessage('exit code: ${pubGetResult.exitCode}')
    ..logDebugMessage(pubGetResult.stdout.toString())
    ..logErrorMessage(pubGetResult.stderr.toString())
    ..endLogGroup();

  if (pubGetResult.exitCode != 0) {
    throw StateError(
      '$executable pub get - returns ${pubGetResult.exitCode}',
    );
  }
}
