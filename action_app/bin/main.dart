import 'dart:io';

import 'package:dart_code_metrics_github_action_app/action_app.dart';

Future<void> main(List<String> args) async {
  final workflowUtils = GitHubWorkflowUtils(
    environmentVariables: Platform.environment,
    output: stdout,
  );

  final arguments = Arguments(workflowUtils);
  await Reporter.create(workflowUtils: workflowUtils, arguments: arguments);
}
