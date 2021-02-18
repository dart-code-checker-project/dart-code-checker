/*
import 'package:meta/meta.dart';

import 'section.dart';

@immutable
class Report {
  final String packageName;
  final int grantedPoints;
  final int maxPoints;
  final String panaVersion;
  final String flutterVersion;
  final String dartSdkVersion;
  final String dartSdkInFlutterVersion;
  final Map<String, Iterable<String>> supportedPlatforms;
  final Iterable<Section> sections;
  final String errorMessage;

  const Report._({
    required this.packageName,
    required this.grantedPoints,
    required this.maxPoints,
    required this.panaVersion,
    required this.dartSdkInFlutterVersion,
    required this.dartSdkVersion,
    required this.flutterVersion,
    required this.supportedPlatforms,
    required this.sections,
    required this.errorMessage,
  });

  factory Report.fromOutput(Map<String, dynamic> output) {
    final packageName = output['packageName'] as String;
    final runtimeInfo = output['runtimeInfo'] as Map<String, Object>;
    final panaVersion = runtimeInfo['panaVersion'] as String;
    final dartSdkVersion = runtimeInfo['sdkVersion'] as String;
    final flutterInfo = runtimeInfo['flutterVersions'] as Map<String, Object>;
    final flutterVersion = flutterInfo['frameworkVersion'] as String;
    final dartInFlutterVersion = flutterInfo['dartSdkVersion'] as String;
    final scores = output['scores'] as Map<String, Object>;
    final grantedPoints = scores['grantedPoints'] as int;
    final maxPoints = scores['maxPoints'] as int;
    final errorMessage = output['errorMessage'] as String;
    final sections = <Section>[];

    final supportedPlatforms = <String, List<String>>{};

    final tags = output['tags'] as List?;
    if (tags != null) {
      tags.cast<String>().forEach((tag) {
        final splitted = tag.split(':');
        if (splitted.length != 2) {
          return;
        }
        switch (splitted.first) {
          case 'platform':
            supportedPlatforms
                .putIfAbsent('Flutter', () => [])
                .add(splitted[1]);
            break;
          case 'runtime':
            supportedPlatforms.putIfAbsent('Dart', () => []).add(splitted[1]);
            break;
        }
      });
    }

    if (output['report'] != null && output['report']!['sections'] != null) {
      (output['report']!['sections']! as List)
          .cast<Map<String, Object>>()
          .forEach((s) => sections.add(Section.fromJSON(s)));
    }

    return Report._(
      packageName: packageName,
      panaVersion: panaVersion,
      flutterVersion: flutterVersion,
      dartSdkInFlutterVersion: dartInFlutterVersion,
      dartSdkVersion: dartSdkVersion,
      supportedPlatforms: supportedPlatforms,
      grantedPoints: grantedPoints,
      maxPoints: maxPoints,
      sections: sections,
      errorMessage: errorMessage,
    );
  }
}
*/
