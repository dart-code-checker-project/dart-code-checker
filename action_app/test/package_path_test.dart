@TestOn('vm')
import 'package:dart_code_metrics_github_action_app/src/package_path.dart';
import 'package:test/test.dart';

void main() {
  test(
    'PackagePath canonicalPackagePath returns canonized path to the package',
    () {
      const pathToRepoRoot = '/home/builder/git';

      expect(
        const PackagePath(
          pathToRepoRoot: pathToRepoRoot,
          relativePath: '/project/',
        ).canonicalPackagePath,
        equals('/home/builder/git/project'),
      );
      expect(
        const PackagePath(pathToRepoRoot: '$pathToRepoRoot/', relativePath: '')
            .canonicalPackagePath,
        equals('/home/builder/git'),
      );
    },
  );
}
