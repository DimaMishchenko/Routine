# Testing Routine

Generate the workspace with `mise exec -- make gen`. Use the **RoutineApp Local** scheme for isolated local storage without an Apple account or CloudKit. Do not seed test routines into the official app's database.

## Automated checks

Boot a simulator owned by your task and use its exact identifier:

```sh
mise exec -- make test SIMULATOR_UDID=YOUR_SIMULATOR_UDID
make secrets
```

Run the native Mac Catalyst tests separately:

```sh
set -o pipefail
xcodebuild test -workspace Routine.xcworkspace -scheme 'RoutineApp Local' \
  -destination 'platform=macOS,variant=Mac Catalyst' 2>&1 | xcbeautify
```

The suite covers local and legacy persistence, explicit history deletion, reminder reconciliation, authentication state, one-time launch presentation, native calendar sizing and state, chart lifetime, and description-cell reuse. Use `make secrets-history` for the additional local Git blob scan before a public-source review.

## Native regression pass

Exercise a compact phone, a large phone, an iPad including a narrow window, iPhone Duo closed and open, and Mac Catalyst. Include the minimum supported runtime, portrait and landscape where available, light and dark appearance, and the largest accessibility text size.

- Fresh preferences: finish onboarding, see the free announcement, continue, then relaunch and confirm it stays dismissed. Existing preferences must show the announcement without replaying onboarding. Locked content must not consume either presentation.
- Open Settings from the toolbar and return. Check appearance, author links, feedback, bundled acknowledgements, and onboarding replay.
- Create a routine with a description, goal, frequency and reminder. Save, reopen, edit another field, and confirm the description and reminder remain. Test keyboard scrolling, cancellation, and deletion.
- Increase and undo progress. Open details, change chart range, select and deselect a calendar date, and confirm history and statistics update without distorting the seven-column calendar or resetting its visible month.
- Check wrapping, reachable controls, progress percentages, and scrolling at maximum text size. Inspect actual pixels as well as accessibility labels.

Production CloudKit setup, import and export can be verified on a provisioned Mac with an iCloud account. Inspect the signed environment entitlement before launching: Prod must use Production, and Dev must use Development. Both signed Prod build configurations open the same real Prod App Group store. Use Dev for experimental routines, and do not switch an existing mirrored store between cloud environments.

Initialize the sync monitor before opening cloud-backed storage. For evidence, inspect completed NSPersistentCloudKitContainer event states; a green idle icon alone is insufficient. A Mac-to-iPhone edit round trip still requires a second signed client. Real biometric authentication and delivered timed reminders need their own native checks. Unit tests and a green simulator build do not prove those flows.

See [Screenshots/README.md](Screenshots/README.md) for localized synthetic fixtures, native capture prerequisites and local artwork rendering. Screenshot generation does not upload or submit a release.
