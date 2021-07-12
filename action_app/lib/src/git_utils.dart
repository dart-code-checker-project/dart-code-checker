import 'dart:io';

import 'github_workflow_utils.dart';

void gitHubAuthSetup(String token, GitHubWorkflowUtils workflowUtils) {
  workflowUtils.startLogGroup('Configure GitHub Auth');

  final hosts = {
    'https://github.com/': 'https://x-access-token:$token@github.com/',
    'git@github.com:': 'https://x-access-token:$token@github.com/',
  };

  for (final host in hosts.entries) {
    final gitResult = Process.runSync('git', [
      'config',
      '--global',
      'url.${host.value}.insteadOf',
      host.key,
    ]);

    workflowUtils
      ..logDebugMessage('Rewrite any "${host.key}" to "${host.value}"')
      ..logDebugMessage('return code ${gitResult.exitCode}')
      ..logDebugMessage(gitResult.stdout.toString())
      ..logErrorMessage(gitResult.stderr.toString());
  }

  workflowUtils.endLogGroup();
}
