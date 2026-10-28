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

Run `make secrets` before sharing a change. Follow [Security](SECURITY.md) for
sensitive findings and publication checks. Changes to dependencies must retain
their licenses and update [third-party notices](THIRD_PARTY_NOTICES.md).

Contributions to project code are provided under the [MIT license](LICENSE).
The repository is currently private; a public contribution channel is not yet
available. Contact [dimasike.dev@gmail.com](mailto:dimasike.dev@gmail.com) to discuss
a fix without including credentials or personal routine data.
