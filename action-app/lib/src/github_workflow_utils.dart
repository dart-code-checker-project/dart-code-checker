import 'dart:convert';
import 'dart:io';

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
String get currentPathToRepoRoot {
  const envVarWorkspace = 'GITHUB_WORKSPACE';
  final repoPath = Platform.environment[envVarWorkspace];
  if (repoPath == null) {
    throw ArgumentError.value(
      repoPath,
      envVarWorkspace,
      "Make sure you call 'actions/checkout' in a previous step. Invalid environment variable",
    );
  }

  return repoPath;
}
