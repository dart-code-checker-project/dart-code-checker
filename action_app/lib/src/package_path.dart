import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

@immutable
class PackagePath {
  final String _pathToRepoRoot;
  final String _relativePath;

  const PackagePath({
    required String pathToRepoRoot,
    required String relativePath,
  })  : _pathToRepoRoot = pathToRepoRoot,
        _relativePath = relativePath;

  /// Canonical path to the package to analyze
  String get canonicalPackagePath =>
      p.canonicalize('$_pathToRepoRoot/$_relativePath');
}
