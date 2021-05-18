@TestOn('vm')
import 'dart:io';

import 'package:dart_code_metrics_github_action_app/src/github_action_input.dart';
import 'package:dart_code_metrics_github_action_app/src/github_workflow_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class IOSinkMock extends Mock implements IOSink {}

void main() {
  group('GitHubWorkflowUtils', () {
    // ignore: close_sinks
    late IOSinkMock output;

    setUp(() {
      output = IOSinkMock();
    });

    group('actionInputValue', () {
      late GitHubWorkflowUtils workflow;

      setUp(() {
        workflow = GitHubWorkflowUtils(
          environmentVariables: {
            'INPUT_GITHUB_TOKEN': '02468A',
            'INPUT_EMPTY': '',
          },
          output: output,
        );
      });

      test('throws ArgumentError for uninitialized input', () {
        expect(
          () {
            workflow.actionInputValue(const GitHubActionInput(
              'token',
              isRequired: true,
              canBeEmpty: false,
            ));
          },
          throwsArgumentError,
        );

        expect(
          () {
            workflow.actionInputValue(const GitHubActionInput(
              'token',
              isRequired: false,
              canBeEmpty: false,
            ));
          },
          throwsArgumentError,
        );

        expect(
          () {
            workflow.actionInputValue(const GitHubActionInput(
              'empty',
              isRequired: false,
              canBeEmpty: false,
            ));
          },
          throwsArgumentError,
        );
      });

      test('returns input value', () {
        expect(
          workflow.actionInputValue(const GitHubActionInput(
            'github token',
            isRequired: true,
            canBeEmpty: false,
          )),
          equals('02468A'),
        );

        expect(
          workflow.actionInputValue(const GitHubActionInput(
            'token',
            isRequired: false,
            canBeEmpty: true,
          )),
          isEmpty,
        );

        expect(
          workflow.actionInputValue(const GitHubActionInput(
            'empty',
            isRequired: true,
            canBeEmpty: true,
          )),
          isEmpty,
        );
      });
    });

    test('currentRepositorySlug returns defined slug of the repository', () {
      expect(
        () {
          GitHubWorkflowUtils(environmentVariables: {}, output: output)
              .currentRepositorySlug();
        },
        throwsArgumentError,
      );

      const slug = 'dart-code-checker/run-dart-code-metrics-action';

      expect(
        GitHubWorkflowUtils(
          environmentVariables: {'GITHUB_REPOSITORY': slug},
          output: output,
        ).currentRepositorySlug(),
        equals(slug),
      );
    });

    test('currentPathToRepoRoot returns workspase path', () {
      expect(
        () {
          GitHubWorkflowUtils(environmentVariables: {}, output: output)
              .currentPathToRepoRoot();
        },
        throwsArgumentError,
      );

      const path = '/user/builder/repository';

      expect(
        GitHubWorkflowUtils(
          environmentVariables: {'GITHUB_WORKSPACE': path},
          output: output,
        ).currentPathToRepoRoot(),
        equals(path),
      );
    });

    test('logDebugMessage logs passed message', () {
      const message = 'simple message';
      const path = '/project/lib/source.dart';

      GitHubWorkflowUtils(environmentVariables: {}, output: output)
          .logDebugMessage(message);
      GitHubWorkflowUtils(environmentVariables: {}, output: output)
          .logDebugMessage(message, file: path);
      GitHubWorkflowUtils(environmentVariables: {}, output: output)
          .logDebugMessage(message, line: 1);
      GitHubWorkflowUtils(environmentVariables: {}, output: output)
          .logDebugMessage(message, column: 2);
      GitHubWorkflowUtils(environmentVariables: {}, output: output)
          .logDebugMessage(
        message,
        file: path,
        line: 1,
        column: 2,
      );

      expect(
        verify(() => output.writeln(captureAny())).captured,
        equals([
          '::debug::simple message',
          '::debug file=/project/lib/source.dart::simple message',
          '::debug line=1::simple message',
          '::debug col=2::simple message',
          '::debug file=/project/lib/source.dart,line=1,col=2::simple message',
        ]),
      );
    });

    test('logErrorMessage logs passed message', () {
      const message = 'simple message';
      const path = '/project/lib/source.dart';

      GitHubWorkflowUtils(environmentVariables: {}, output: output)
          .logErrorMessage(message);
      GitHubWorkflowUtils(environmentVariables: {}, output: output)
          .logErrorMessage(message, file: path);
      GitHubWorkflowUtils(environmentVariables: {}, output: output)
          .logErrorMessage(message, line: 1);
      GitHubWorkflowUtils(environmentVariables: {}, output: output)
          .logErrorMessage(message, column: 2);
      GitHubWorkflowUtils(environmentVariables: {}, output: output)
          .logErrorMessage(
        message,
        file: path,
        line: 1,
        column: 2,
      );

      expect(
        verify(() => output.writeln(captureAny())).captured,
        equals([
          '::error::simple message',
          '::error file=/project/lib/source.dart::simple message',
          '::error line=1::simple message',
          '::error col=2::simple message',
          '::error file=/project/lib/source.dart,line=1,col=2::simple message',
        ]),
      );
    });

    test('logInfoMessage logs passed message', () {
      const message = 'simple message';

      GitHubWorkflowUtils(environmentVariables: {}, output: output)
          .logInfoMessage(message);

      expect(
        verify(() => output.writeln(captureAny())).captured,
        equals([message]),
      );
    });

    test('logWarningMessage logs passed message', () {
      const message = 'simple message';
      const path = '/project/lib/source.dart';

      GitHubWorkflowUtils(environmentVariables: {}, output: output)
          .logWarningMessage(message);
      GitHubWorkflowUtils(environmentVariables: {}, output: output)
          .logWarningMessage(message, file: path);
      GitHubWorkflowUtils(environmentVariables: {}, output: output)
          .logWarningMessage(message, line: 1);
      GitHubWorkflowUtils(environmentVariables: {}, output: output)
          .logWarningMessage(message, column: 2);
      GitHubWorkflowUtils(environmentVariables: {}, output: output)
          .logWarningMessage(
        message,
        file: path,
        line: 1,
        column: 2,
      );

      expect(
        verify(() => output.writeln(captureAny())).captured,
        equals([
          '::warning::simple message',
          '::warning file=/project/lib/source.dart::simple message',
          '::warning line=1::simple message',
          '::warning col=2::simple message',
          '::warning file=/project/lib/source.dart,line=1,col=2::simple message',
        ]),
      );
    });

    test('startLogGroup logs command about start grouping log messages', () {
      GitHubWorkflowUtils(environmentVariables: {}, output: output)
          .startLogGroup('group name');

      expect(
        verify(() => output.writeln(captureAny())).captured.single,
        equals('::group::group name'),
      );
    });
  });
}
