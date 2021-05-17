import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'github_workflow_utils.dart';

@immutable
class PackagePath {
  final GitHubWorkflowUtils _workflowUtils;
  final String _relativePath;

  const PackagePath({
    required GitHubWorkflowUtils workflowUtils,
    required String relativePath,
  })  : _workflowUtils = workflowUtils,
        _relativePath = relativePath;

  /// Canonical path to the package to analyze
  String get canonicalPackagePath => p
      .canonicalize('${_workflowUtils.currentPathToRepoRoot()}/$_relativePath');
}
