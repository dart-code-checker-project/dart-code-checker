import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import 'github_workflow_utils.dart';

@immutable
class PackagePath {
  final String relativePath;

  const PackagePath({required this.relativePath});

  /// Canonical path to the package to analyze
  String get canonicalPackagePath =>
      path.canonicalize('$currentPathToRepoRoot()/$relativePath');
}
