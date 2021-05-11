import 'dart:io';

import 'package:dart_code_metrics/config.dart';
import 'package:dart_code_metrics/metrics_analyzer.dart';
import 'package:dart_code_metrics_github_action_app/action_app.dart';

Future<void> main(List<String> args) async {
  final workflowUtils = GitHubWorkflowUtils(stdout);

  final arguments = Arguments();
  final analysis = await Analysis.start(arguments);

  try {
    await analysis.run();

    workflowUtils.startLogGroup('Running dart code metrics');

    const foldersToAnalyze = ['lib'];
    final rootFolder = arguments.packagePath.canonicalPackagePath;
    final options = await analysisOptionsFromFilePath(rootFolder);
    final config = Config.fromAnalysisOptions(options);
    final lintConfig = ConfigBuilder.getLintConfig(config, rootFolder);

    final result = await const LintAnalyzer()
        .runCliAnalysis(foldersToAnalyze, rootFolder, lintConfig);

    await analysis.complete(result);
  } on Exception catch (cause) {
    try {
      await analysis.cancel(cause: cause);
      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      workflowUtils.logErrorMessage('$error\n$stackTrace');
    }
  }
}
