import 'dart:io';

import 'package:meta/meta.dart';

const _unknownPackageName = 'unknown';

const _flutterKey = 'flutter';
const _pubspecYaml = 'pubspec.yaml';
const _packageNameKey = 'name:';

@immutable
class PubSpecUtils {
  final Iterable<String> _content;

  const PubSpecUtils(this._content);

  bool get isFlutterPackage =>
      _content.any((line) => line.trim().startsWith(_flutterKey));

  String get packageName {
    if (_content.any((line) => line.contains(_packageNameKey))) {
      return _content
          .firstWhere((line) => line.contains(_packageNameKey))
          .split(_packageNameKey)
          .last
          .trim();
    }

    return _unknownPackageName;
  }
}

PubSpecUtils readPubspec(String canonicalPackagePath) {
  final pubspec = File('$canonicalPackagePath/$_pubspecYaml');
  final pubspecContent =
      pubspec.existsSync() ? pubspec.readAsLinesSync() : <String>[];

  return PubSpecUtils(pubspecContent);
}
