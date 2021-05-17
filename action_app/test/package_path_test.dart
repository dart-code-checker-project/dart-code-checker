@TestOn('vm')
import 'package:dart_code_metrics_github_action_app/src/github_workflow_utils.dart';
import 'package:dart_code_metrics_github_action_app/src/package_path.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class GitHubWorkflowUtilsMock extends Mock implements GitHubWorkflowUtils {}

void main() {
  group('PackagePath', () {
    late GitHubWorkflowUtilsMock workflowUtilsMock;

    setUp(() {
      workflowUtilsMock = GitHubWorkflowUtilsMock();
    });

    test('canonicalPackagePath returns canonized path to the package', () {
      when(workflowUtilsMock.currentPathToRepoRoot)
          .thenReturn('/home/builder/git');

      expect(
        PackagePath(
          workflowUtils: workflowUtilsMock,
          relativePath: '/project/',
        ).canonicalPackagePath,
        equals('/home/builder/git/project'),
      );
      expect(
        PackagePath(workflowUtils: workflowUtilsMock, relativePath: '')
            .canonicalPackagePath,
        equals('/home/builder/git'),
      );
    });
  });
}
