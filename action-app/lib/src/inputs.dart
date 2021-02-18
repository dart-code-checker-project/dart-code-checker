/*
import 'dart:convert';
import 'dart:io';

import 'package:github_actions_toolkit/github_actions_toolkit.dart';

import 'github_workflow_utils.dart';
import 'paths.dart';

const Input githubTokenInput = Input(
      'githubToken',
      isRequired: false,
      canBeEmpty: true,
    ),
    packagePathInput = Input(
      'relativePath',
      isRequired: false,
      canBeEmpty: true,
    );

class Inputs {
  /// Token to call the GitHub API
  final String githubToken;

  /// Head SHA of the commit associated to the current workflow
  final String commitSha;

  /// Slug of the repository
  final String repositorySlug;

  final Paths paths;

  factory Inputs() {
    final paths = Paths(packagePathInput.value ?? '');

    if (!Directory(paths.canonicalPathToPackage).existsSync()) {
      throw ArgumentError.value(
        paths.canonicalPathToPackage,
        packagePathInput.name,
        "This directory doesn't exist in your repository",
      );
    }

    return Inputs._(
      commitSha: currentCommitSHA(),
      githubToken: Platform.environment['GITHUB_TOKEN'],
      //githubTokenInput.value,
      paths: paths,
      repositorySlug: currentRepositorySlug(),
    );
  }

  Inputs._({
    required this.commitSha,
    required this.githubToken,
    required this.paths,
    required this.repositorySlug,
  });

  static String get _sha {
    final pathEventPayload = Platform.environment['GITHUB_EVENT_PATH'];
    final eventPayload = jsonDecode(File(pathEventPayload).readAsStringSync())
        as Map<String, Object>;
    final commitSha = Platform.environment['GITHUB_SHA'];
    stderr.writeln('SHA that triggered the workflow: $commitSha');
    final pullRequest = eventPayload['pull_request'] as Map<String, Object>;
    if (pullRequest != null) {
      final baseSha =
          (pullRequest['base'] as Map<String, Object>)['sha'] as String;
      final headSha =
          (pullRequest['head'] as Map<String, Object>)['sha'] as String;
      if (commitSha != headSha) {
        stderr..writeln('Base SHA: $baseSha')..writeln('Head SHA: $headSha');

        return headSha;
      }
    }

    return commitSha;
  }
}
*/
