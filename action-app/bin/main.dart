/*
import 'dart:convert';
import 'dart:io';

import 'package:dart_code_metrics_github_action_app/src/github.dart';
import 'package:dart_code_metrics_github_action_app/src/inputs.dart';
import 'package:dart_code_metrics_github_action_app/src/report.dart';
import 'package:github_actions_toolkit/github_actions_toolkit.dart' as gaction;

const logger = gaction.log;
*/
void main() {
/*  
  exitCode = 0;

  // Parsing user inputs and environment variables
  final inputs = Inputs();

  final analysis = await Analysis.queue(
    commitSha: inputs.commitSha,
    githubToken: inputs.githubToken,
    repositorySlug: inputs.repositorySlug,
  );

  Future<void> tryCancelAnalysis(Object cause) async {
    try {
      await analysis.cancel(cause: cause);
    } catch (error, stackTrace) {
      logger.error('$error${stackTrace != null ? '\n$stackTrace' : ''}');
    }
  }

  Future<void> _exitProgram() async {
    await tryCancelAnalysis(null);
    await Future.wait<void>([stderr.done, stdout.done]);
    logger.error('Exiting with code $exitCode');
    exit(exitCode);
  }

  try {
    // Command to disable analytics reporting, and also to prevent a warning from the next command due to Flutter welcome screen
    await logger.group(
      'Disabling Flutter analytics',
      () => gaction.exec('flutter', const <String>['config', '--no-analytics']),
    );

    await analysis.start();

    // Executing the analysis
    logger.startGroup('Running pana');
    final panaProcessResult = await gaction.exec(
      'pana',
      <String>[
        '--json',
        '--no-warning',
        inputs.paths.canonicalPathToPackage,
      ],
    );
    logger.endGroup();

    if (panaProcessResult.exitCode != 0) {
      logger.error('Pana exited with code ${panaProcessResult.exitCode}');
      exitCode = panaProcessResult.exitCode;
      await _exitProgram();
    }
    if (panaProcessResult.stderr
        .toString()
        .contains('Invalid kernel binary format version')) {
      throw Exception('SDK incompatibility');
    }
    if (panaProcessResult.stdout == null) {
      throw Exception('The pana command has returned no valid output.'
          ' This should never happen.'
          ' Please file an issue at https://github.com/axel-op/dart-package-analyzer/issues/new');
    }

    final report = Report.fromOutput(
        jsonDecode(panaProcessResult.stdout.toString())
            as Map<String, dynamic>);

    if (report.errorMessage != null) {
      throw Exception(report.errorMessage);
    }

    // Posting comments on GitHub
    await logger.group(
      'Publishing report',
      () async => analysis.complete(report: report),
    );

    // Setting outputs
    await logger.group(
      'Setting outputs',
      () async {
        final outputs = {
          'total': report.grantedPoints?.toString(),
          'total_max': report.maxPoints?.toString(),
        };
        final idsToKeys = {
          'convention': 'conventions',
          'documentation': 'documentation',
          'platform': 'platforms',
          'analysis': 'analysis',
          'dependency': 'dependencies',
          'null-safety': 'null_safety',
        };
        for (final section in report.sections) {
          final key = idsToKeys[section.id] ?? section.id;
          outputs[key] = section.grantedPoints?.toString();
          outputs['${key}_max'] = section.maxPoints?.toString();
        }
        for (final output in outputs.entries) {
          logger.info('${output.key}: ${output.value}');
          gaction.setOutput(output.key, output.value);
        }
      },
    );
  } catch (e) {
    //_writeErrors(e, s); // useless if we rethrow it
    await tryCancelAnalysis(e);
    rethrow;
  }
*/
}
