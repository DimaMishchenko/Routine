# Release automation

Local development needs neither Ruby nor an Apple account. For release automation,
install the Gemfile dependencies with `bundle install`, use Tuist through mise,
and install `xcbeautify`. Xcode must already be signed into an authorized Apple
Developer account. The lanes use automatic signing; keep credentials in Xcode
and Keychain. See [Security](../SECURITY.md).

## Select a candidate

Set `Modules/RoutineApp/app-version` before generating. Set `TUIST_BUILD_NUMBER`
to an unused positive integer; Mac builds must also increase beyond earlier Mac
uploads across marketing versions. Keep the same value for export and upload.
The lanes do not modify either value.

Outputs live under `.artifacts/releases/ENV/DESTINATION/VERSION-BUILD/`.
Existing archives and export/upload directories are preserved; choose a new build
number for a replacement candidate. A fork must supply its own provisioning,
bundle IDs and CloudKit configuration; `DEVELOPMENT_TEAM` overrides the team.

## Archive and export

After setting the candidate's version and build number:

```sh
mise exec -- bundle exec fastlane ios export_app_store environment:prod destination:ios
mise exec -- bundle exec fastlane ios export_app_store environment:prod destination:macos
```

These commands generate, archive and export without uploading. `macos` selects
universal Mac Catalyst; `environment:dev` selects the separate Dev configuration.
Review the signed app, production push/CloudKit entitlements, provisioning and Mac
installer signature. Do not use a global `CODE_SIGN_IDENTITY` override: codeless
SwiftPM resource bundles must be sealed by the enclosing app's signature.

## Upload a reviewed archive

Check Apple agreements and retain the same `TUIST_BUILD_NUMBER` before uploading:

```sh
mise exec -- bundle exec fastlane ios upload_testflight environment:prod destination:ios
mise exec -- bundle exec fastlane ios upload_testflight environment:prod destination:macos
```

Upload uses an existing archive and does not rebuild. An optional
`archive_path:/absolute/path/to/Routine.xcarchive` selects another reviewed archive.
The lane checks its bundle ID, team and platform, and rejects separately signed
codeless Mac resource bundles.

Upload transfers the candidate to App Store Connect. Confirm server processing,
export compliance and TestFlight installation separately; transfer success does
not prove installability. The lanes do not accept agreements, add testers, submit
App Review, release the app or change Git refs. Account login or legal acceptance
requires owner action. `skip_docs` preserves this manually maintained guide.
