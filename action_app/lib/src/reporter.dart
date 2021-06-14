import 'dart:math';

import 'package:github/github.dart';

import 'arguments.dart';
import 'github_workflow_utils.dart';

class Reporter {
  static Future<Reporter> create({
    required GitHubWorkflowUtils workflowUtils,
    required Arguments arguments,
  }) async {
    try {
      final id = '${Random().nextInt(1000)}';

      workflowUtils.logDebugMessage('Id attributed to checkrun: $id');

      return Reporter._();
    } on GitHubError catch (e) {
      if (e.toString().contains('Resource not accessible by integration')) {
        workflowUtils.logWarningMessage(
          "It seems that this action doesn't have the required permissions to call the GitHub API with the token you gave. "
          "This can occur if this repository is a fork, as in that case GitHub reduces the GITHUB_TOKEN's permissions for security reasons. "
          'Consequently, no report will be made on GitHub.',
        );

        return Reporter._();
      }
      rethrow;
    }
  }

  Reporter._();
}
