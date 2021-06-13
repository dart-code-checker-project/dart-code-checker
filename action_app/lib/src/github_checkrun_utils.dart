// ignore: implementation_imports
import 'package:dart_code_metrics/src/analyzers/lint_analyzer/models/issue.dart'
    as dcm;
// ignore: implementation_imports
import 'package:dart_code_metrics/src/analyzers/lint_analyzer/models/severity.dart'
    as dcm;
import 'package:github/github.dart' as github;
import 'package:path/path.dart' as p;

import 'github_workflow_utils.dart';

class GitHubCheckRunUtils {
  final GitHubWorkflowUtils _workflowUtils;

  const GitHubCheckRunUtils(this._workflowUtils);

  github.CheckRunAnnotation issueToAnnotation(
    String sourceAbsolutePath,
    dcm.Issue issue,
  ) {
    final isSingleLineIssue =
        issue.location.start.line == issue.location.end.line;

    final detailedMessage = [
      if (issue.verboseMessage != null) issue.verboseMessage!,
      if (issue.suggestion != null) issue.suggestion!.comment,
    ].join('\n');

    return github.CheckRunAnnotation(
      path: p.relative(
        sourceAbsolutePath,
        from: _workflowUtils.currentPathToRepoRoot(),
      ),
      startLine: issue.location.start.line,
      endLine: issue.location.end.line,
      startColumn: isSingleLineIssue ? issue.location.start.column : null,
      endColumn: isSingleLineIssue ? issue.location.end.column : null,
      annotationLevel: severityToAnnotationLevel(issue.severity),
      message: detailedMessage.isNotEmpty ? detailedMessage : issue.message,
      title: detailedMessage.isNotEmpty ? issue.message : '',
    );
  }

  github.CheckRunAnnotationLevel severityToAnnotationLevel(
    dcm.Severity severity,
  ) {
    if (_severityMapping.containsKey(severity)) {
      return _severityMapping[severity]!;
    }

    _workflowUtils.logInfoMessage('Unknow severity: $severity');

    return github.CheckRunAnnotationLevel.notice;
  }
}

const _severityMapping = {
  dcm.Severity.style: github.CheckRunAnnotationLevel.notice,
  dcm.Severity.performance: github.CheckRunAnnotationLevel.warning,
  dcm.Severity.warning: github.CheckRunAnnotationLevel.warning,
  dcm.Severity.error: github.CheckRunAnnotationLevel.failure,
};
