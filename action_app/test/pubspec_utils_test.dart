@TestOn('vm')
import 'package:action_app/src/pubspec_utils.dart';
import 'package:test/test.dart';

const _dartPackage = [
  'name: action_app',
  'version: 1.0.0',
  'description: Github action app that helps to run dart_code_metrics in CI/CD flow.',
  'homepage: https://github.com/dart-code-checker/dart-code-metrics-action',
  'issue_tracker: https://github.com/dart-code-checker/dart-code-metrics-action/issues',
  'publish_to: none',
  '',
  'environment:',
  '  sdk: ">=2.12.0 <3.0.0"',
  '',
  'dependencies:',
  '  dart_code_metrics: ^4.0.0-dev.5',
  '  github: ^8.1.0',
  '  meta: ^1.4.0',
  '  path: ^1.8.0',
  '',
  'dev_dependencies:',
  '  coverage: ^1.0.2',
  '  mocktail: ^0.1.4',
  '  pedantic: ^1.11.0',
  '  source_span: ^1.8.0',
  '  test: ^1.17.3',
];

const _flutterPackage = [
  'name: mwwm',
  'version: 2.0.0',
  'description: |',
  '  Software architecture pattern for teams with different sizes. Add possibility to work separately. Separate UI, presentation logic and business logic.',
  'repository: "https://github.com/surfstudio/SurfGear/tree/main/packages/mwwm"',
  'issue_tracker: "https://github.com/surfstudio/SurfGear/issues"',
  '',
  'dependencies:',
  '  flutter:',
  '    sdk: flutter',
  '',
  'dev_dependencies:',
  '  flutter_test:',
  '    sdk: flutter',
  '  mocktail: ^0.1.1',
  '  surf_lint_rules: ^1.0.0',
  '',
  'environment:',
  '  sdk: ">=2.12.0 <3.0.0"',
  '',
  'flutter:',
];

void main() {
  group('PackageUtils', () {
    group('isFlutterPackage returns', () {
      test('false on empty content', () {
        const pubSpecUtils = PubSpecUtils([]);

        expect(pubSpecUtils.isFlutterPackage, isFalse);
      });

      test('false on Dart package content', () {
        const pubSpecUtils = PubSpecUtils(_dartPackage);

        expect(pubSpecUtils.isFlutterPackage, isFalse);
      });

      test('true on Flutter package content', () {
        const pubSpecUtils = PubSpecUtils(_flutterPackage);

        expect(pubSpecUtils.isFlutterPackage, isTrue);
      });
    });

    group('packageName returns', () {
      test('"unknown" on empty content', () {
        const pubSpecUtils = PubSpecUtils([]);

        expect(pubSpecUtils.packageName, equals('unknown'));
      });

      test('package name', () {
        const pubSpecUtils = PubSpecUtils(_dartPackage);

        expect(
          pubSpecUtils.packageName,
          equals('action_app'),
        );
      });
    });
  });
}
