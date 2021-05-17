const _unknownPackageName = 'unknown';

const _packageNameKey = 'name:';

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
