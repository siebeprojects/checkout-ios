fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```

Build framework and run tests

### ios build_example_swift

```sh
[bundle exec] fastlane ios build_example_swift
```

Build example app (Swift)

### ios browserstack

```sh
[bundle exec] fastlane ios browserstack
```

Upload binary to Browserstack

### ios ui_test

```sh
[bundle exec] fastlane ios ui_test
```

Run UI tests

### ios submit_to_testflight

```sh
[bundle exec] fastlane ios submit_to_testflight
```

Submit to TestFlight

### ios set_version

```sh
[bundle exec] fastlane ios set_version
```

Change version number

### ios deploy

```sh
[bundle exec] fastlane ios deploy
```

Deploy

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
