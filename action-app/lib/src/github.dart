/*
import 'dart:io';
import 'dart:math';

import 'package:github/github.dart';
import 'package:github_actions_toolkit/github_actions_toolkit.dart' as gaction;

import 'report.dart';

final _useTestMode = Platform.environment['GITHUB_REPOSITORY'] ==
    'axel-op/dart-package-analyzer';

extension on String {
  bool equalsIgnoreCase(String other) => other.toLowerCase() == toLowerCase();
}

extension on Report {
  static const tagsDocs = {
    'native-jit':
        'Can be run with the dart vm in jit mode. (Can use dart:io and dart:mirrors)',
    'native-aot':
        'Can be aot compiled with eg. dart2native (Can use dart:io but not dart:mirrors)',
    'web':
        'Can be compiled with DDC and dart2js. (Can use dart:html and friends, not dart:io, dart:mirrors, dart:ffi, etc.)',
  };

  CheckRunConclusion get conclusion =>
      errorMessage != null || grantedPoints == null || maxPoints == null
          ? CheckRunConclusion.failure
          : CheckRunConclusion.success;

  String get summary {
    final summary = StringBuffer();

    if (grantedPoints != null && maxPoints != null) {
      summary
        ..writeln('### Score')
        ..writeln('**$grantedPoints/$maxPoints** points')
        ..writeln('(${grantedPoints * 100.0 / maxPoints}%)');
    }

    final platforms = supportedPlatforms;
    if (platforms.isNotEmpty) {
      summary.write('\n### Supported platforms');
    }
    for (final platform in supportedPlatforms.keys) {
      summary.write('\n* $platform');
      platforms[platform].forEach((tag) {
        summary.write('\n  * `$tag`');
        if (platform.equalsIgnoreCase('dart') && tagsDocs.containsKey(tag)) {
          summary.write('  \n${tagsDocs[tag]}');
        }
      });
    }

    return summary.toString();
  }

  String get text {
    final text = StringBuffer();

    for (final section in sections) {
      final summary = section.summary.splitMapJoin(
        RegExp(r'# \[(.)\] '),
        onMatch: (m) {
          switch (m.group(1)) {
            case '*':
              return '# ✔ ';
            case 'x':
              return '# ❌ ';
            case '~':
              return '# ⚠ ';
            default:
              return m.group(0);
          }
        },
      );
      text
        ..write('## ${section.title}')
        ..write(' (${section.grantedPoints}/${section.maxPoints})')
        ..write('\n\n$summary\n\n');
    }

    text.write('\n## Versions'
        '\n* [Pana: $panaVersion](https://pub.dev/packages/pana/versions/$panaVersion)'
        '\n* Dart: $dartSdkVersion'
        '\n* Flutter: $flutterVersion');
    if (dartSdkVersion != dartSdkInFlutterVersion) {
      text.write(' with Dart $dartSdkInFlutterVersion');
    }

    return text.toString();
  }
}

class Analysis {
  static Future<Analysis> queue({
    required String repositorySlug,
    required String githubToken,
    required String commitSha,
  }) async {
    final client = GitHub(auth: Authentication.withToken(githubToken));
    final slug = RepositorySlug.full(repositorySlug);
    try {
      final id = Random().nextInt(1000).toString();
      final name = StringBuffer('Dart package analysis');
      gaction.log.debug('Id attributed to checkrun: $id');
      if (_useTestMode) {
        name.write(' ($id)');
      }
      final checkRun = await client.checks.checkRuns.createCheckRun(
        slug,
        status: CheckRunStatus.queued,
        name: name.toString(),
        headSha: commitSha,
        externalId: id,
      );

      return Analysis._(client, checkRun, slug);
    } catch (e) {
      if (e is GitHubError &&
          e.message.contains('Resource not accessible by integration')) {
        gaction.log.warning(
            " It seems that this action doesn't have the required permissions to call the GitHub API with the token you gave."
            " This can occur if this repository is a fork, as in that case GitHub reduces the GITHUB_TOKEN's permissions for security reasons."
            ' Consequently, no report will be made on GitHub.'
            ' Check this issue for more information:'
            ' https://github.com/axel-op/dart-package-analyzer/issues/2');

        return Analysis._(client, null, slug);
      }
      rethrow;
    }
  }

  final GitHub _client;

  /// No report will be posted on GitHub if this is null.
  final CheckRun _checkRun;
  final RepositorySlug _repositorySlug;
  DateTime _startTime;

  Analysis._(
    this._client,
    this._checkRun,
    this._repositorySlug,
  );

  Future<void> start() async {
    if (_checkRun == null) {
      return;
    }
    _startTime = DateTime.now();
    await _client.checks.checkRuns.updateCheckRun(
      _repositorySlug,
      _checkRun,
      startedAt: _startTime,
      status: CheckRunStatus.inProgress,
    );
  }

  Future<void> cancel({Object cause}) async {
    if (_checkRun == null) {
      return;
    }
    gaction.log.debug("Checkrun cancelled. Conclusion is 'CANCELLED'.");
    await _client.checks.checkRuns.updateCheckRun(
      _repositorySlug,
      _checkRun,
      startedAt: _startTime,
      completedAt: DateTime.now(),
      status: CheckRunStatus.completed,
      conclusion: _useTestMode
          ? CheckRunConclusion.neutral
          : CheckRunConclusion.cancelled,
      output: cause == null
          ? null
          : CheckRunOutput(
              title: _checkRun.name,
              summary:
                  'This check run has been cancelled, due to the following error:'
                  '\n\n```\n$cause\n```\n\n'
                  'Check your logs for more information.',
            ),
    );
  }

  Future<void> complete({
    required Report report,
  }) async {
    final conclusion = report.conclusion;
    if (_checkRun == null) {
      if (conclusion == CheckRunConclusion.failure) {
        gaction.log.error(
            'Static analysis has detected one or more compile-time errors.'
            ' As no report can be posted, this action will directly fail.');
        exitCode = 1;
      }

      return;
    }
    final title = StringBuffer('Package analysis results');
    if (report.packageName != null) {
      title.write(' for ${report.packageName}');
    }
    final summary = StringBuffer();
    final name = StringBuffer('Analysis of ${report.packageName}');
    if (_useTestMode) {
      summary
        ..writeln('**THIS ACTION HAS BEEN EXECUTED IN TEST MODE.**')
        ..writeln('**Conclusion = `$conclusion`**');
      name.write(' (${_checkRun.externalId})');
    }
    summary.writeln(report.summary);
    final checkRun = await _client.checks.checkRuns.updateCheckRun(
      _repositorySlug,
      _checkRun,
      name: name.toString(),
      status: CheckRunStatus.completed,
      startedAt: _startTime,
      completedAt: DateTime.now(),
      conclusion: _useTestMode ? CheckRunConclusion.neutral : conclusion,
      output: CheckRunOutput(
        title: title.toString(),
        summary: summary.toString(),
        text: report.text,
        annotations: const [],
      ),
    );
    gaction.log
      ..info('Check Run Id: ${checkRun.id}')
      ..info('Check Suite Id: ${checkRun.checkSuiteId}')
      ..info('Report posted at: ${checkRun.detailsUrl}');
  }
}
*/
