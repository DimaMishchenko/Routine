# Contributing

Use the pinned Tuist version in `mise.toml`, generate the project, and run the
Local scheme before sending a pull request. Do not commit generated Xcode projects,
workspaces, build outputs, credentials, provisioning profiles or personal signing
settings. Keep `.package.resolved` aligned with manifest dependency changes.

For behavior changes, include a focused XCTest or a clear manual verification path.
For UI changes, include screenshots and the tested device/runtime. Distinguish a
successful build from behavior tested on a simulator or a signed device. Test
reminders with notifications allowed and denied, and CloudKit only in a correctly
provisioned build. Keep iPhone, iPad, iOS 26 and Catalyst compatibility unless a
change explains why those targets must move.

Use an owned simulator by UDID. Stop only simulators and helpers you created; never
restart global simulator services as a troubleshooting shortcut.

Run `make secrets` before publishing. Follow SECURITY.md for sensitive findings.
Changes to dependencies must retain their licenses and update third-party notices.
