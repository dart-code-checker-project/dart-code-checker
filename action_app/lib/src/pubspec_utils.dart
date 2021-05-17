import 'dart:io';

import 'package:meta/meta.dart';

const _unknownPackageName = 'unknown';

const _pubspecYaml = 'pubspec.yaml';
const _packageNameKey = 'name:';

@immutable
class PubSpecUtils {
  final Iterable<String> _content;

  const PubSpecUtils(this._content);

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

PubSpecUtils pubspec(String canonicalPackagePath) {
  final pubspec = File('$canonicalPackagePath/$_pubspecYaml');
  final pubspecContent =
      pubspec.existsSync() ? pubspec.readAsLinesSync() : <String>[];

  return PubSpecUtils(pubspecContent);
}
