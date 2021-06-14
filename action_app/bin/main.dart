import 'dart:io';

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
  } on Exception catch (cause) {
    try {
      await reporting.cancel(cause: cause);
      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      workflowUtils.logErrorMessage('$error\n$stackTrace');
    }
  }
}
