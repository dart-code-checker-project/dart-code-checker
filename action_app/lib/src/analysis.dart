import 'dart:math';

import 'package:github/github.dart';

import 'arguments.dart';
import 'github_workflow_utils.dart';

const _checkRunName = 'Dart Code Metrics report';
const _homePage = 'https://github.com/dart-code-checker/dart-code-metrics';

class Analysis {
  static Future<Analysis> start(Arguments arguments) async {
    final client =
        GitHub(auth: Authentication.withToken(arguments.githubToken));
    final slug = RepositorySlug.full(arguments.repositorySlug);
    try {
      final id = '${Random().nextInt(1000)}';
      final name = isTestMode() ? '$_checkRunName ($id)' : _checkRunName;

      logDebugMessage('Id attributed to checkrun: $id');

      final checkRun = await client.checks.checkRuns.createCheckRun(
        slug,
        name: name.toString(),
        headSha: arguments.commitSha,
        status: CheckRunStatus.queued,
        detailsUrl: _homePage,
        externalId: id,
      );

      return Analysis._(client, checkRun, slug);
    } on GitHubError catch (e) {
      if (e.toString().contains('Resource not accessible by integration')) {
        logWarningMessage(
          "It seems that this action doesn't have the required permissions to call the GitHub API with the token you gave. "
          "This can occur if this repository is a fork, as in that case GitHub reduces the GITHUB_TOKEN's permissions for security reasons. "
          'Consequently, no report will be made on GitHub.',
        );

        return Analysis._(client, null, slug);
      }
      rethrow;
    }
  }

  final GitHub _client;
  final CheckRun? _checkRun;
  final RepositorySlug _repositorySlug;
  final DateTime _startTime;

  Analysis._(
    this._client,
    this._checkRun,
    this._repositorySlug,
  ) : _startTime = DateTime.now();

  Future<void> run() async {
    if (_checkRun == null) {
      return;
    }

    await _client.checks.checkRuns.updateCheckRun(
      _repositorySlug,
      _checkRun!,
      startedAt: _startTime,
      status: CheckRunStatus.inProgress,
    );
  }
}
