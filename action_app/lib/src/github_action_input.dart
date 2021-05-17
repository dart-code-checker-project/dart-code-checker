import 'package:meta/meta.dart';

/// Objects that represent an input of the action
@immutable
class GitHubActionInput {
  /// The name of the input, as written in the YAML file.
  final String name;

  final bool isRequired;
  final bool canBeEmpty;

  const GitHubActionInput(
    this.name, {
    required this.isRequired,
    this.canBeEmpty = true,
  });
}
