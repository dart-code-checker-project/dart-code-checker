import 'dart:convert';
import 'dart:io';

const _envVarGitHubWorkspace = 'GITHUB_WORKSPACE';

/// Returns head SHA of the commit associated to the current workflow
String currentCommitSHA() {
  final commitSha = Platform.environment['GITHUB_SHA'] as String;
  stderr.writeln('SHA that triggered the workflow: $commitSha');

  final pathEventPayload = Platform.environment['GITHUB_EVENT_PATH'];
  if (pathEventPayload != null) {
    final eventPayload = jsonDecode(File(pathEventPayload).readAsStringSync())
        as Map<String, dynamic>;

    final pullRequest = eventPayload['pull_request'] as Map<String, dynamic>?;
    if (pullRequest != null) {
      final baseSha =
          (pullRequest['base'] as Map<String, dynamic>)['sha'] as String;
      final headSha =
          (pullRequest['head'] as Map<String, dynamic>)['sha'] as String;
      if (commitSha != headSha) {
        stderr..writeln('Base SHA: $baseSha')..writeln('Head SHA: $headSha');

        return headSha;
      }
    }
  }

  return commitSha;
}

/// Returns slug of the repository
String currentRepositorySlug() =>
    Platform.environment['GITHUB_REPOSITORY'] as String;

/// Path to the folder containing the entire repository
String currentPathToRepoRoot() {
  final repoPath = Platform.environment[_envVarGitHubWorkspace];
  if (repoPath == null) {
    throw ArgumentError.value(
      repoPath,
      _envVarGitHubWorkspace,
      "Make sure you call 'actions/checkout' in a previous step. Invalid environment variable",
    );
  }

  return repoPath;
}

void _echo(String command, {String? message, Map<String, String>? parameters}) {
  final sb = StringBuffer('::$command');

  final params =
      parameters?.entries.map((e) => '${e.key}=${e.value}').join(',');
  if (params != null && params.isNotEmpty) {
    sb.write(' $params');
  }
  sb.write('::');
  if (message != null) {
    sb.write(message);
  }

  stdout.writeln(sb.toString());
}
