@TestOn('vm')
import 'package:dart_code_metrics/src/analyzers/models/severity.dart';
import 'package:dart_code_metrics_github_action_app/src/github_checkrun_utils.dart';
import 'package:dart_code_metrics_github_action_app/src/github_workflow_utils.dart';
import 'package:github/github.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class GitHubWorkflowUtilsMock extends Mock implements GitHubWorkflowUtils {}

void main() {
  group('severityToAnnotationLevel returns', () {
    late GitHubWorkflowUtilsMock workflowUtilsMock;

    setUp(() {
      workflowUtilsMock = GitHubWorkflowUtilsMock();
    });

    test('github annotation level from dart_code_metrics severity', () {
      final utils = GitHubCheckRunUtils(workflowUtilsMock);

      expect(
        utils.severityToAnnotationLevel(Severity.warning),
        equals(CheckRunAnnotationLevel.warning),
      );
      verifyNever(() => workflowUtilsMock.logInfoMessage(any()));
    });

    test(
      'github annotation level notice from unknown dart_code_metrics severity',
      () {
        final utils = GitHubCheckRunUtils(workflowUtilsMock);

        expect(
          utils.severityToAnnotationLevel(Severity.none),
          equals(CheckRunAnnotationLevel.notice),
        );
        expect(
          verify(() => workflowUtilsMock.logInfoMessage(captureAny())).captured,
          equals(['Unknow severity: none']),
        );
      },
    );
  });
}
