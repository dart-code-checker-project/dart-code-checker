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
