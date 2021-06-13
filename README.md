<!-- markdownlint-disable MD041 -->
[![Build Status](https://shields.io/github/workflow/status/dart-code-checker/run-dart-code-metrics-action/test?logo=github&logoColor=white)](https://github.com/dart-code-checker/run-dart-code-metrics-action/)
[![Coverage Status](https://img.shields.io/codecov/c/github/dart-code-checker/run-dart-code-metrics-action?logo=codecov&logoColor=white)](https://codecov.io/gh/dart-code-checker/run-dart-code-metrics-action/)
[![License](https://img.shields.io/github/license/dart-code-checker/run-dart-code-metrics-action)](https://github.com/dart-code-checker/run-dart-code-metrics-action/blob/master/LICENSE)
<!-- markdownlint-enable MD041 -->

# Dart Code Metrics Action

This action allows to use Dart Code Metrics from GitHub Actions.

## What is Dart Code Metrics?

[Dart Code Metrics](https://github.com/dart-code-checker/dart-code-metrics) is a static analysis tool that helps you analyse and improve your code quality.

## Usage

Create `dartcodemetrics.yml` under `.github/workflows` With the following contents.

### Default configuration

```yml
name: dart-code-metrics-action

on: [push]

jobs:
  check:
    name: dart-code-metrics

    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2
          
      - name: dart-code-metrics
        uses: dart-code-checker/dart-code-metrics-action@main
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Inputs

| Name | Required | Description | Default |
| :--- | :--- | :--- | :--- |
| **githubToken**  | ☑️ | Required to post a report on GitHub. *Note:* the secret [`GITHUB_TOKEN`](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/authenticating-with-the-github_token) is already provided by GitHub and you don't have to set it up yourself. | |
| **relativePath** | | If your package isn't at the root of the repository, set this input to indicate its location. | |
