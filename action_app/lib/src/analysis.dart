import 'dart:io';
import 'dart:math';

import 'package:dart_code_metrics/reporters.dart';
// ignore: implementation_imports
import 'package:dart_code_metrics/src/analyzers/models/severity.dart';
import 'package:github/github.dart';

import 'arguments.dart';
import 'github_checkrun_utils.dart';
import 'github_workflow_utils.dart';

const _checkRunName = 'Dart Code Metrics report';
const _homePage = 'https://github.com/dart-code-checker/dart-code-metrics';

class Analysis {
  static Future<Analysis> start(Arguments arguments) async {
    final workflowUtils = GitHubWorkflowUtils(stdout);

    final client =
        GitHub(auth: Authentication.withToken(arguments.githubToken));
    final slug = RepositorySlug.full(arguments.repositorySlug);
    try {
      final id = '${Random().nextInt(1000)}';
      final name =
          workflowUtils.isTestMode() ? '$_checkRunName ($id)' : _checkRunName;

      workflowUtils.logDebugMessage('Id attributed to checkrun: $id');

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
        workflowUtils.logWarningMessage(
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

  Analysis._(this._client, this._checkRun, this._repositorySlug)
      : _startTime = DateTime.now();

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

  Future<void> complete(Iterable<FileReport> report) async {
    if (_checkRun == null) {
      return;
    }

    final workflowUtils = GitHubWorkflowUtils(stdout);
    final checkRunUtils = GitHubCheckRunUtils(workflowUtils);

    final conclusion = report.any((file) => [
              ...file.antiPatternCases,
              ...file.issues,
            ].any((issue) => issue.severity != Severity.none))
        ? CheckRunConclusion.failure
        : CheckRunConclusion.success;

    const title = 'Package analysis results';

    final name = StringBuffer('Analysis of repository');
    final summary = StringBuffer();
    if (workflowUtils.isTestMode()) {
      name.write(' (${_checkRun?.externalId})');
      summary
        ..writeln('**THIS ACTION HAS BEEN EXECUTED IN TEST MODE.**')
        ..writeln('**Conclusion = `$conclusion`**');
    }

    final checkRun = await _client.checks.checkRuns.updateCheckRun(
      _repositorySlug,
      _checkRun!,
      name: name.toString(),
      status: CheckRunStatus.completed,
      startedAt: _startTime,
      completedAt: DateTime.now(),
      conclusion:
          workflowUtils.isTestMode() ? CheckRunConclusion.neutral : conclusion,
      output: CheckRunOutput(
        title: title,
        summary: summary.toString(),
        text: 'simple report',
        annotations: report
            .map((file) => [
                  ...file.antiPatternCases.map(
                    (issue) =>
                        checkRunUtils.issueToAnnotation(file.path, issue),
                  ),
                  ...file.issues.map(
                    (issue) =>
                        checkRunUtils.issueToAnnotation(file.path, issue),
                  ),
                ])
            .expand((issues) => issues)
            .toList()
              ..forEach((issue) {
                workflowUtils.logDebugMessage('issue: ${issue.toJson()}');
              }),
      ),
    );

    workflowUtils
      ..logInfoMessage('Check Run Id: ${checkRun.id}')
      ..logInfoMessage('Check Suite Id: ${checkRun.checkSuiteId}')
      ..logInfoMessage('Report posted at: ${checkRun.detailsUrl}');
  }

  Future<void> cancel({required Exception cause}) async {
    if (_checkRun == null) {
      return;
    }

    final workflowUtils = GitHubWorkflowUtils(stdout)
      ..logDebugMessage("Checkrun cancelled. Conclusion is 'CANCELLED'.");
    await _client.checks.checkRuns.updateCheckRun(
      _repositorySlug,
      _checkRun!,
      startedAt: _startTime,
      completedAt: DateTime.now(),
      status: CheckRunStatus.completed,
      conclusion: workflowUtils.isTestMode()
          ? CheckRunConclusion.neutral
          : CheckRunConclusion.cancelled,
      output: CheckRunOutput(
        title: _checkRun?.name ?? '',
        summary:
            'This check run has been cancelled, due to the following error:'
            '\n\n```\n$cause\n```\n\n'
            'Check your logs for more information.',
      ),
    );
  }
}
