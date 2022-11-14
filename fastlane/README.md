fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### upload_tf_routine_dev

```sh
[bundle exec] fastlane upload_tf_routine_dev
```

Upload RoutineApp Dev to Testflight



Parameters

- version (required) - build version

### upload_tf_routine_prod

```sh
[bundle exec] fastlane upload_tf_routine_prod
```

Upload RoutineApp Prod to Testflight

----


## iOS

### ios upload_tf_routine

```sh
[bundle exec] fastlane ios upload_tf_routine
```

Upload RoutineApp to Testflight



Parameters

- version (required) - build version

- bundle_id (required) - app bundle id

- scheme (required) - app scheme

- groups (optional) - tester groups to assign

----


## Mac

### mac upload_tf_routine

```sh
[bundle exec] fastlane mac upload_tf_routine
```

Upload RoutineApp to Testflight



Parameters

- version (required) - build version

- bundle_id (required) - app bundle id

- scheme (required) - app scheme

- groups (optional) - tester groups to assign

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
