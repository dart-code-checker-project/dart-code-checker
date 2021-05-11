import 'dart:io';

import 'github_action_input.dart';
import 'github_workflow_utils.dart';
import 'package_path.dart';

const _githubTokenInput = ActionInput(
  'githubToken',
  isRequired: true,
  canBeEmpty: false,
);

const _packagePathInput = ActionInput(
  'relativePath',
  isRequired: false,
  canBeEmpty: true,
);

class Arguments {
  /// Token to call the GitHub API
  final String githubToken;

  /// Head SHA of the commit associated to the current workflow
  final String commitSha;

  /// Slug of the repository
  final String repositorySlug;

  final PackagePath packagePath;

  factory Arguments() {
    final packagePath = PackagePath(relativePath: _packagePathInput.value);

    if (!Directory(packagePath.canonicalPackagePath).existsSync()) {
      throw ArgumentError.value(
        packagePath.canonicalPackagePath,
        _packagePathInput.value,
        "This directory doesn't exist in your repository",
      );
    }

    final workflowUtils = GitHubWorkflowUtils(stdout);

    return Arguments._(
      githubToken: _githubTokenInput.value,
      commitSha: workflowUtils.currentCommitSHA(),
      repositorySlug: workflowUtils.currentRepositorySlug(),
      packagePath: packagePath,
    );
  }

  Arguments._({
    required this.githubToken,
    required this.commitSha,
    required this.repositorySlug,
    required this.packagePath,
  });
}
