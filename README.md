<!-- markdownlint-disable MD041 -->
[![Build Status](https://shields.io/github/workflow/status/dart-code-checker/dart-code-metrics-action/test?logo=github&logoColor=white)](https://github.com/dart-code-checker/dart-code-metrics-action/)
[![Action Version](https://img.shields.io/badge/action-v1.0.0-blue?logo=github&logoColor=white)](https://github.com/marketplace/actions/dart-code-metrics-action/)
[![License](https://img.shields.io/github/license/dart-code-checker/dart-code-metrics-action)](https://github.com/dart-code-checker/dart-code-metrics-action/blob/master/LICENSE)
[![GitHub popularity](https://img.shields.io/github/stars/dart-code-checker/dart-code-metrics-action?logo=github&logoColor=white)](https://github.com/dart-code-checker/dart-code-metrics-action/stargazers)
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

| Name              | Required                                                                  | Description                                                                                                                                                                                                                                                                                                         | Default |
| :---------------- | :------------------------------------------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :------ |
| **github_token**  | ☑️                                                                         | Required to post a report on GitHub. *Note:* the secret [`GITHUB_TOKEN`](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/authenticating-with-the-github_token) is already provided by GitHub and you don't have to set it up yourself.                                              |         |
| **folders**       |                                                                           | List of folders whose contents will be scanned.                                                                                                                                                                                                                                                                     | [`lib`] |
| **relative_path** |                                                                           | If your package isn't at the root of the repository, set this input to indicate its location.                                                                                                                                                                                                                       |         |
| **github_pat**    | Required if you had private GitHub repository in the package dependencies | [**Personal access token**](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) must access to *repo* and *read:user* [scopes](https://docs.github.com/en/developers/apps/building-oauth-apps/scopes-for-oauth-apps#available-scopes) |         |

### Output Example

* Check run output:
  
  <img
  src="https://raw.githubusercontent.com/dart-code-checker/dart-code-metrics-action/master/doc/.assets/check_run_output.png"
  alt="annotation"
  height="341,5" width="597"
  align="center">

* Annotation:

  <img
  src="https://raw.githubusercontent.com/dart-code-checker/dart-code-metrics-action/master/doc/.assets/annotation.png"
  alt="annotation"
  height="197" width="608"
  align="center">
