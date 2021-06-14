@TestOn('vm')
import 'package:action_app/src/pubspec_utils.dart';
import 'package:test/test.dart';

void main() {
  group('PackageUtils packageName returns', () {
    test('"unknown" on empty content', () {
      const pubSpecUtils = PubSpecUtils([]);

      expect(pubSpecUtils.packageName, equals('unknown'));
    });

    test('package name', () {
      const pubSpecUtils = PubSpecUtils([
        'name: action_app',
        'version: 1.0.0',
        'description: Github action app that helps to run dart_code_metrics in CI/CD flow.',
        'homepage: https://github.com/dart-code-checker/dart-code-metrics-action',
        'issue_tracker: https://github.com/dart-code-checker/dart-code-metrics-action/issues',
        'publish_to: none',
      ]);

      expect(
        pubSpecUtils.packageName,
        equals('action_app'),
      );
    });
  });
}
