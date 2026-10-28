# Contributing

Routine is in maintenance mode. Contributions should focus on reproducible bug
fixes, compatibility with supported Apple platforms, security, accessibility and
small documentation improvements. Discuss larger changes before investing in
implementation. There is no guaranteed review, support or release schedule.

Use the pinned Tuist version in `mise.toml`, generate the project, and run the
Local scheme before preparing a change. The [README](README.md#build-locally)
contains the build commands. Do not commit generated Xcode projects, workspaces,
build outputs, credentials, provisioning profiles or personal signing settings.
Keep `.package.resolved` aligned with manifest dependency changes.

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
