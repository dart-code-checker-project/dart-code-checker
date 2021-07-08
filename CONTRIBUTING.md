# Contribution guide

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
