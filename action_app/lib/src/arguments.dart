import 'dart:io';

import 'github_action_input.dart';
import 'github_workflow_utils.dart';
import 'package_path.dart';

const _githubTokenInput = GitHubActionInput(
  'githubToken',
  isRequired: true,
  canBeEmpty: false,
);

const _packagePathInput = GitHubActionInput(
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
    final workflowUtils = GitHubWorkflowUtils(
      environmentVariables: Platform.environment,
      output: stdout,
    );

    final packagePath = PackagePath(
      workflowUtils: workflowUtils,
      relativePath: workflowUtils.actionInputValue(_packagePathInput),
    );

    if (!Directory(packagePath.canonicalPackagePath).existsSync()) {
      throw ArgumentError.value(
        packagePath.canonicalPackagePath,
        workflowUtils.actionInputValue(_packagePathInput),
        "This directory doesn't exist in your repository",
      );
    }

    return Arguments._(
      githubToken: workflowUtils.actionInputValue(_githubTokenInput),
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
