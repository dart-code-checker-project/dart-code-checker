# Contribution guide

## GitHub limitations

Unfortunately, there are some known issues and limitations caused by GitHub API:

* Report (i.e. Check Run summary) is markdown text. No custom styling or HTML is possible.
* Maximum report size is 65535 bytes.
* Report can't reference any additional files (e.g. screenshots). You can use [`actions/upload-artifact@v2`](https://github.com/marketplace/actions/upload-a-build-artifact) to upload them and inspect them manually.
* Check Runs are created for specific commit SHA. It's not possible to specify under which workflow test report should belong if more workflows are running for the same SHA. For more information, see [community post](https://github.community/t/github-actions-status-checks-created-on-incorrect-check-suite-id/16685) and [another one](https://github.community/t/specify-check-suite-when-creating-a-checkrun/118380).

## Git commit message convention

```text
  <type>(<scope>): <subject>
```

### type - one of the following

* `build`: build related changes (eg: pub related/ adding external dependencies)
* `chore`: a code change that external user won't see (eg: change to .gitignore file)
* `feat`: a new feature
* `fix`: a bug fix
* `docs`: documentation related changes
* `refactor`: a code that neither fix bug nor adds a feature. (eg: we can use this when there is semantic changes like renaming a variable/ function name)
* `perf`: a code that improves performance
* `style`: a code that is related to styling
* `test`: adding new test or making changes to existing test

### scope

* scope must be noun and it represents the section of the section of the codebase
* [refer this link for example related to scope](http://karma-runner.github.io/1.0/dev/git-commit-msg.html#example-scope-values)

### subject

* use imperative, present tense (eg: use "add" instead of "added" or "adds")
* don't use punctuation at the end
* don't capitalize first letter
