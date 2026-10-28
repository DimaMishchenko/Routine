# Contributing

Routine is in maintenance mode. Contributions should focus on reproducible bug
fixes, compatibility with supported Apple platforms, security, accessibility and
small documentation improvements. Discuss larger changes before investing in
implementation. There is no guaranteed review, support or release schedule.

## Development

Use macOS with Xcode 27.1, an iOS Simulator runtime, [mise](https://mise.jdx.dev/)
and [xcbeautify](https://github.com/cpisciotta/xcbeautify). Tuist 4.209.0 is pinned
in `mise.toml`; dependencies are pinned in the manifests and `.package.resolved`.
The app targets iOS/iPadOS 26+ and macOS 26+ through Mac Catalyst.

```sh
mise install
mise exec -- make build
open Routine.xcworkspace
```

`make build` generates the workspace before building. Select **RoutineApp Local**
and an iOS Simulator. Local uses an isolated bundle ID and local Core Data store,
with no Apple account, developer team, CloudKit entitlements or service credentials.
Build Catalyst with:

```sh
mise exec -- make build DESTINATION='generic/platform=macOS,variant=Mac Catalyst'
```

Run [tests and native checks](TESTING.md) before preparing a change. Do not commit
generated projects, workspaces, build outputs, credentials, provisioning profiles
or personal signing settings. Keep `.package.resolved` aligned with dependency changes.

### Cloud builds

**RoutineApp Dev** and **RoutineApp Prod** require matching Apple Developer
provisioning, CloudKit containers and a development team. Local cannot access
official cloud data. Forks must supply their own bundle IDs, containers and provisioning.

Dev uses a separate app identity, App Group store and **Development** CloudKit
environment for experiments. Prod opens the official app's store and **Production**
CloudKit environment, including when development-signed. Keep disposable data in Dev.
Real cross-device synchronization requires signed clients; simulator tests alone
are insufficient.

TestFlight and App Store deployment run locally through the [release lanes](fastlane/README.md).
Do not add signing credentials or app-upload workflows to GitHub Actions.

## Preparing a change

For behavior changes, include a focused XCTest or a clear manual verification path.
For UI changes, include screenshots and the tested device/runtime. Distinguish a
successful build from behavior tested on a simulator or a signed device. Test
reminders with notifications allowed and denied, and CloudKit only in a correctly
provisioned Dev build with disposable data. Keep iPhone, iPad, iOS 26 and Catalyst
compatibility unless a change explains why those targets must move.

Use an owned simulator by UDID. Stop only simulators and helpers you created; never
restart global simulator services as a troubleshooting shortcut.

Follow [Security](SECURITY.md) for sensitive findings and credential handling.
Dependency changes must retain their licenses and update
[third-party notices](THIRD_PARTY_NOTICES.md).

Contributions to project code are provided under the [MIT license](LICENSE).
Use [GitHub issues](https://github.com/DimaMishchenko/Routine/issues) to report a
reproducible bug or discuss a fix, and open a pull request for a focused change.
Keep credentials and personal routine data out of public reports. Send sensitive
findings privately as described in [Security](SECURITY.md).
