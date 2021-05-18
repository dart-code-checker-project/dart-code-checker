import 'dart:convert';
import 'dart:io';

import 'github_action_input.dart';

const _envVarGitHubWorkspace = 'GITHUB_WORKSPACE';
const _envVarGitHubRepositorySlug = 'GITHUB_REPOSITORY';
const _envVarGitHubSHA = 'GITHUB_SHA';

const _checkOutError =
    "Make sure you call 'actions/checkout' in a previous step. Invalid environment variable";

class GitHubWorkflowUtils {
  final Map<String, String> _environmentVariables;
  final IOSink _output;

  const GitHubWorkflowUtils({
    required Map<String, String> environmentVariables,
    required IOSink output,
  })  : _environmentVariables = environmentVariables,
        _output = output;

  /// Will throw an [ArgumentError] if the [input] is required and the value is
  /// null or if the value is an empty string and input canBeEmpty is false.
  String actionInputValue(GitHubActionInput input) {
    final key = 'INPUT_${input.name.toUpperCase().replaceAll(" ", "_")}';
    final value = _environmentVariables[key];
    if ((value == null && input.isRequired) ||
        ((value == null || value.isEmpty) && !input.canBeEmpty)) {
      throw ArgumentError(
        "No value was given for the argument '${input.name}'.",
      );
    }

    return value ?? '';
  }

  /// Returns head SHA of the commit associated to the current workflow
  String currentCommitSHA() {
    final commitSha = _environmentVariables[_envVarGitHubSHA];
    if (commitSha == null) {
      throw ArgumentError.value(
        commitSha,
        _envVarGitHubRepositorySlug,
        _checkOutError,
      );
    }

    logDebugMessage('SHA that triggered the workflow: $commitSha');

    final pathEventPayload = _environmentVariables['GITHUB_EVENT_PATH'];
    if (pathEventPayload != null) {
      final eventPayload = jsonDecode(File(pathEventPayload).readAsStringSync())
          as Map<String, dynamic>;

      final pullRequest = eventPayload['pull_request'] as Map<String, dynamic>?;
      if (pullRequest != null) {
        final baseSha =
            (pullRequest['base'] as Map<String, dynamic>)['sha'] as String;
        final headSha =
            (pullRequest['head'] as Map<String, dynamic>)['sha'] as String;
        if (commitSha != headSha) {
          logDebugMessage('Base SHA: $baseSha');
          logDebugMessage('Head SHA: $headSha');

          return headSha;
        }
      }
    }

    return commitSha;
  }

  /// Returns slug of the repository
  String currentRepositorySlug() {
    final repoPath = _environmentVariables[_envVarGitHubRepositorySlug];
    if (repoPath == null) {
      throw ArgumentError.value(
        repoPath,
        _envVarGitHubRepositorySlug,
        _checkOutError,
      );
    }

    return repoPath;
  }

  /// Path to the folder containing the entire repository
  String currentPathToRepoRoot() {
    final repoPath = _environmentVariables[_envVarGitHubWorkspace];
    if (repoPath == null) {
      throw ArgumentError.value(
        repoPath,
        _envVarGitHubWorkspace,
        _checkOutError,
      );
    }

    return repoPath;
  }

  /// Prints a debug message to the log.
  ///
  /// You must [enabling step debug logging](https://docs.github.com/en/actions/managing-workflow-runs/enabling-debug-logging#enabling-step-debug-logging)
  /// to see the debug messages set by this command in the log.
  /// To learn more about creating secrets and using them in a step,
  /// see "[Creating and using encrypted secrets.](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets)"
  void logDebugMessage(
    String message, {
    String? file,
    int? line,
    int? column,
  }) {
    _log('debug', message, file, line, column);
  }

  /// Creates an error message and prints the message to the log.
  ///
  /// You can optionally provide a filename ([file]), line number ([line]), and column ([column]) number where the warning occurred.
  void logErrorMessage(
    String message, {
    String? file,
    int? line,
    int? column,
  }) {
    _log('error', message, file, line, column);
  }

  void logInfoMessage(String message) {
    _output.writeln(message);
  }

  /// Creates a warning message and prints the message to the log.
  ///
  /// You can optionally provide a filename ([file]), line number ([line]), and column ([column]) number where the warning occurred.
  void logWarningMessage(
    String message, {
    String? file,
    int? line,
    int? column,
  }) {
    _log('warning', message, file, line, column);
  }

  void startLogGroup(String groupName) {
    _echo('group', message: groupName);
  }

  void endLogGroup() {
    _echo('endgroup');
  }

  bool isTestMode() =>
      currentRepositorySlug() ==
      'dart-code-checker/run-dart-code-metrics-action';

  void _echo(
    String command, {
    String? message,
    Map<String, String>? parameters,
  }) {
    var params =
        parameters?.entries.map((e) => '${e.key}=${e.value}').join(',') ?? '';
    if (params.isNotEmpty) {
      params = ' $params';
    }

    _output.writeln('::$command$params::${message ?? ''}');
  }

// ignore: long-parameter-list
  void _log(
    String command,
    String message,
    String? file,
    int? line,
    int? column,
  ) {
    final parameters = {
      if (file != null) 'file': file,
      if (line != null) 'line': '$line',
      if (column != null) 'col': '$column',
    };

    _echo(command, message: message, parameters: parameters);
  }
}
