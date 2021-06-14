import 'dart:math';

// ignore: implementation_imports
import 'package:dart_code_metrics/src/analyzers/lint_analyzer/models/lint_file_report.dart';
// ignore: implementation_imports
import 'package:dart_code_metrics/src/analyzers/lint_analyzer/models/severity.dart';

import 'package:github/github.dart';

import 'arguments.dart';
import 'github_checkrun_utils.dart';
import 'github_workflow_utils.dart';

const _checkRunName = 'Dart Code Metrics report';
const _homePage = 'https://github.com/dart-code-checker/dart-code-metrics';

class Reporter {
  static Future<Reporter> create({
    required GitHubWorkflowUtils workflowUtils,
    required Arguments arguments,
  }) async {
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

      return Reporter._(client, workflowUtils, checkRun, slug);
    } on GitHubError catch (e) {
      if (e.toString().contains('Resource not accessible by integration')) {
        workflowUtils.logWarningMessage(
          "It seems that this action doesn't have the required permissions to call the GitHub API with the token you gave. "
          "This can occur if this repository is a fork, as in that case GitHub reduces the GITHUB_TOKEN's permissions for security reasons. "
          'Consequently, no report will be made on GitHub.',
        );

        return Reporter._(client, workflowUtils, null, slug);
      }
      rethrow;
    }
  }

  final GitHub _client;
  final GitHubWorkflowUtils _workflowUtils;
  final CheckRun? _checkRun;
  final RepositorySlug _repositorySlug;
  final DateTime _startTime;

  Reporter._(
    this._client,
    this._workflowUtils,
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

  Future<void> complete(
    Iterable<LintFileReport> report,
    String packageName,
  ) async {
    if (_checkRun == null) {
      return;
    }

    final checkRunUtils = GitHubCheckRunUtils(_workflowUtils);

    final conclusion = report.any((file) => [
              ...file.antiPatternCases,
              ...file.issues,
            ].any((issue) => issue.severity != Severity.none))
        ? CheckRunConclusion.failure
        : CheckRunConclusion.success;

    final title = _generateTitle(packageName);

    final summary = StringBuffer();
    if (_workflowUtils.isTestMode()) {
      summary
        ..writeln('**THIS ACTION HAS BEEN EXECUTED IN TEST MODE.**')
        ..writeln('**Conclusion = `$conclusion`**');
    }

    summary.write(_generateSummary());

    final details = _generateDetails();

    final checkRun = await _client.checks.checkRuns.updateCheckRun(
      _repositorySlug,
      _checkRun!,
      status: CheckRunStatus.completed,
      startedAt: _startTime,
      completedAt: DateTime.now(),
      conclusion:
          _workflowUtils.isTestMode() ? CheckRunConclusion.neutral : conclusion,
      output: CheckRunOutput(
        title: title,
        summary: summary.toString(),
        text: details,
        annotations: report
            .map(
              (file) => [...file.issues, ...file.antiPatternCases].map(
                (issue) => checkRunUtils.issueToAnnotation(file.path, issue),
              ),
            )
            .expand((issues) => issues)
            .toList(),
      ),
    );

    _workflowUtils
      ..logInfoMessage('Check Run Id: ${checkRun.id}')
      ..logInfoMessage('Check Suite Id: ${checkRun.checkSuiteId}')
      ..logInfoMessage('Report posted at: ${checkRun.detailsUrl}');
  }

  Future<void> cancel({required Exception cause}) async {
    if (_checkRun == null) {
      return;
    }

    _workflowUtils
        .logDebugMessage("Checkrun cancelled. Conclusion is 'CANCELLED'.");
    await _client.checks.checkRuns.updateCheckRun(
      _repositorySlug,
      _checkRun!,
      startedAt: _startTime,
      completedAt: DateTime.now(),
      status: CheckRunStatus.completed,
      conclusion: _workflowUtils.isTestMode()
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

  String _generateTitle(String packageName) =>
      '$packageName package analysis results';

  String _generateDetails() => 'Detailed report';

  String _generateSummary() => '';
}
