// ignore: implementation_imports
import 'dart:io';

// ignore: implementation_imports
import 'package:dart_code_metrics/src/analyzers/models/issue.dart' as dcm;
// ignore: implementation_imports
import 'package:dart_code_metrics/src/analyzers/models/severity.dart' as dcm;
import 'package:github/github.dart' as github;

import 'github_workflow_utils.dart';

class GitHubCheckRunUtils {
  final GitHubWorkflowUtils _workflowUtils;

  const GitHubCheckRunUtils(this._workflowUtils);

  bool isSupportIssue(dcm.Issue issue) => issue.location.sourceUrl != null;

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
