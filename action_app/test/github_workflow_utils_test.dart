@TestOn('vm')
import 'dart:io';

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

    test('logDebugMessage logs passed message', () {
      const message = 'simple message';
      const path = '/project/lib/source.dart';

      GitHubWorkflowUtils(output).logDebugMessage(message);
      GitHubWorkflowUtils(output).logDebugMessage(message, file: path);
      GitHubWorkflowUtils(output).logDebugMessage(message, line: 1);
      GitHubWorkflowUtils(output).logDebugMessage(message, column: 2);
      GitHubWorkflowUtils(output).logDebugMessage(
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

    test('logInfoMessage logs passed message', () {
      const message = 'simple message';

      GitHubWorkflowUtils(output).logInfoMessage(message);

      expect(
        verify(() => output.writeln(captureAny())).captured,
        equals([message]),
      );
    });
  });
}
