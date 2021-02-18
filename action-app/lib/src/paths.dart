/*
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

const _envVarWorkspace = 'GITHUB_WORKSPACE';

String _canonicalPathToRepoRoot() {
  final repoPath = Platform.environment[_envVarWorkspace];

  if (repoPath == null) {
    throw ArgumentError.value(
      repoPath,
      _envVarWorkspace,
      "Make sure you call 'actions/checkout' in a previous step. Invalid environment variable",
    );
  }

  return repoPath;
}

@immutable
class Paths {
  final String packageRelativePath;

  const Paths(this.packageRelativePath);

  /// Canonical path to the package to analyze
  String get canonicalPathToPackage =>
      path.canonicalize('${_canonicalPathToRepoRoot()}/$packageRelativePath');
}
*/
