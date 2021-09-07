fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Build framework and run tests
### ios build_example
```
fastlane ios build_example
```
Build example app
### ios browserstack
```
fastlane ios browserstack
```
Upload binary to Browserstack
### ios ui_test
```
fastlane ios ui_test
```
Run UI tests
### ios submit_to_testflight
```
fastlane ios submit_to_testflight
```
Submit to TestFlight
### ios bump_version_number
```
fastlane ios bump_version_number
```
Bump minor version and commit
### ios lib_lint
```
fastlane ios lib_lint
```
Validate framework for CocoaPods
### ios deploy
```
fastlane ios deploy
```
Deploy

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
