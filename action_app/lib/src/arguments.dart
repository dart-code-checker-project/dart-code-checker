import 'dart:io';

import 'package:path/path.dart' as p;

import 'github_action_input.dart';
import 'github_workflow_utils.dart';
import 'package_path.dart';

const _checkUnusedFilesInput = GitHubActionInput(
  'check_unused_files',
  isRequired: false,
  canBeEmpty: true,
);

const _foldersInput =
    GitHubActionInput('folders', isRequired: false, canBeEmpty: true);

const _githubTokenInput =
    GitHubActionInput('github_token', isRequired: true, canBeEmpty: false);

const _githubPersonalAccessTokenInput =
    GitHubActionInput('github_pat', isRequired: false, canBeEmpty: true);

const _packagePathInput =
    GitHubActionInput('relative_path', isRequired: false, canBeEmpty: true);

const _defaultFolders = ['lib'];

const _pubspecYaml = 'pubspec.yaml';

class Arguments {
  /// Is need to find unused files
  final bool checkUnusedFiles;

  /// Token to call the GitHub API
  final String gitHubToken;

  /// Token for access to private repos on GitHub
  final String gitHubPersonalAccessTokenKey;

  /// Head SHA of the commit associated to the current workflow
  final String commitSha;

  /// Slug of the repository
  final String repositorySlug;

  final PackagePath packagePath;

  final Iterable<String> folders;

  factory Arguments(GitHubWorkflowUtils workflowUtils) {
    final packagePath = PackagePath(
      pathToRepoRoot: workflowUtils.currentPathToRepoRoot(),
      relativePath: workflowUtils.actionInputValue(_packagePathInput),
    );

    if (!Directory(packagePath.canonicalPackagePath).existsSync()) {
      throw ArgumentError.value(
        packagePath.canonicalPackagePath,
        workflowUtils.actionInputValue(_packagePathInput),
        "This directory doesn't exist in your repository",
      );
    }

    if (!File(p.join(packagePath.canonicalPackagePath, _pubspecYaml))
        .existsSync()) {
      throw ArgumentError.value(
        packagePath.canonicalPackagePath,
        workflowUtils.actionInputValue(_packagePathInput),
        "This directory doesn't contains Dart/Flutter package",
      );
    }

    final checkUnusedFiles = {'true', 'yes', '1'}.contains(
      workflowUtils.actionInputValue(_checkUnusedFilesInput).toLowerCase(),
    );

    final folders = workflowUtils
        .actionInputValue(_foldersInput)
        .split(',')
        .map((folder) => folder.trim())
        .where((folder) => folder.isNotEmpty)
        .toSet();

    return Arguments._(
      checkUnusedFiles: checkUnusedFiles,
      gitHubToken: workflowUtils.actionInputValue(_githubTokenInput),
      gitHubPersonalAccessTokenKey:
          workflowUtils.actionInputValue(_githubPersonalAccessTokenInput),
      commitSha: workflowUtils.currentCommitSHA(),
      repositorySlug: workflowUtils.currentRepositorySlug(),
      packagePath: packagePath,
      folders: folders.isNotEmpty ? folders : _defaultFolders,
    );
  }

  Arguments._({
    required this.checkUnusedFiles,
    required this.gitHubToken,
    required this.gitHubPersonalAccessTokenKey,
    required this.commitSha,
    required this.repositorySlug,
    required this.packagePath,
    required this.folders,
  });
}
