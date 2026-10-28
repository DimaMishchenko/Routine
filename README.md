# Routine

Routine is a free, open-source routine and habit tracker for iPhone and iPad, with
Mac Catalyst support. Create routines, track goals and history, schedule local
reminders, and protect the app with device authentication. Every feature is
available without a subscription or app account.

## Build locally

Use macOS with Xcode and an installed iOS Simulator runtime. The revival is being
validated with Xcode 27.1 (27A9275), Swift 5 language mode, and Tuist 4.209.0.
The minimum deployment target is iOS/iPadOS 26.0. The standalone Mac app uses
Catalyst to reuse the UIKit interface.
Validation on iOS 27 simulators does not establish runtime testing on iOS 26.
Install [mise](https://mise.jdx.dev/) and `xcbeautify`, then:

```sh
mise install
mise exec -- make gen
mise exec -- make build
open Routine.xcworkspace
```

Select **RoutineApp Local** in Xcode. Local builds use an isolated bundle ID,
local Core Data storage, and no developer team or CloudKit entitlements. They do
not need Firebase, RevenueCat, signing certificates, API private keys, Ruby, CocoaPods
or an Apple account. Dependency versions, including DGCharts 5.1.0 and SnapKit 5.7.1, are pinned;
`.package.resolved` retains the transitive resolution. SwiftLint is optional.

To run tests, create/boot your own simulator and pass its exact UDID:

```sh
mise exec -- make test SIMULATOR_UDID=YOUR_SIMULATOR_UDID
```

`make test` uses the already generated project. The XCTest suite covers persistence
and reminder planning. Build Catalyst with:

```sh
mise exec -- make build DESTINATION='generic/platform=macOS,variant=Mac Catalyst'
```

## Cloud sync and device signing

The **RoutineApp Dev** and **RoutineApp Prod** schemes preserve the original bundle
IDs and CloudKit entitlement files for the official app. They require matching
Apple Developer provisioning, iCloud containers, push capability, and a development
team selected in Xcode. Local data and official-app data are intentionally separate.
Local builds cannot access the official CloudKit containers. For a fork, supply your
own bundle IDs, entitlement/container IDs and provisioning before enabling sync.
Simulator tests cannot establish production CloudKit sync or signed device behavior.

## Releases

The optional [Fastlane lane](fastlane/README.md) accepts credentials only from the
environment and a private-key file outside this checkout. It archives and uploads
when explicitly invoked; it does not commit, tag, push or submit for App Review.
Run `make secrets` scans the working tree; `make secrets-history` scans all
locally stored Git blobs, including unreachable historical copies. The scanner has
limited high-confidence patterns and does not replace credential review.

## Privacy and contributions

See [Privacy](PRIVACY.md), [Contributing](CONTRIBUTING.md), and
[Security](SECURITY.md). Routine uses the [MIT license](LICENSE); bundled libraries
retain their [own licenses](THIRD_PARTY_NOTICES.md).
