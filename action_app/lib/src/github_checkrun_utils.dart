// ignore: implementation_imports
import 'package:dart_code_metrics/src/analyzers/models/severity.dart';
import 'package:github/github.dart';

import 'github_workflow_utils.dart';

class GitHubCheckRunUtils {
  final GitHubWorkflowUtils _workflowUtils;

  const GitHubCheckRunUtils(this._workflowUtils);

  CheckRunAnnotationLevel severityToAnnotationLevel(Severity severity) {
    if (_severityMapping.containsKey(severity)) {
      return _severityMapping[severity]!;
    }

    _workflowUtils.logInfoMessage('Unknow severity: $severity');

    return CheckRunAnnotationLevel.notice;
  }
}

const _severityMapping = {
  Severity.style: CheckRunAnnotationLevel.notice,
  Severity.performance: CheckRunAnnotationLevel.warning,
  Severity.warning: CheckRunAnnotationLevel.warning,
  Severity.error: CheckRunAnnotationLevel.failure,
};
