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
### ios upload_tf_routine_dev
```
fastlane ios upload_tf_routine_dev
```
Upload RoutineApp Dev to Testflight



Parameters

- version(required) - build version
### ios create_routine_app_ids
```
fastlane ios create_routine_app_ids
```
Create app ids for RoutineApp

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
