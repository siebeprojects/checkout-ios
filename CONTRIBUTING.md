# Contributing to this repository

### Code linting
You should lint your code using [SwiftLint](https://github.com/realm/SwiftLint) before each commit.

To make that process easier you could install [that Git hook](docs/git-hook-precommit.sh) that will check code before each commit:

```bash
# run this in the project's root folder
cp docs/git-hook-precommit.sh .git/hooks/pre-commit
```