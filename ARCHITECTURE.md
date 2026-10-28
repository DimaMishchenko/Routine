# Architecture

Routine keeps its existing UIKit screens, Combine observation and Core Data model.
SwiftUI supplies selected charts and controls. This revival does not replace the
UI framework or migrate users to a new database.

## Ownership

- `App/AppRuntime` lazily opens storage and owns the shared service factory.
  Scenes and headless intents consume that same successful factory. Failed opens
  are not cached, so retry can reopen the existing store.
- `App/SceneDelegate` assembles navigation from the runtime and owns scene
  authentication. Store-opening failures show a retry screen without creating a
  replacement store or deleting data.
- Screen folders under `Sources/Module` own their presenters/view models,
  assemblies, local navigation outputs and views. Assemblies inject the existing
  service protocols; presenters do not initialize third-party services.
- `RoutineStore` owns persistent routine operations and publishes committed
  snapshots. Core Data entities map into the app's routine/history/reminder values.
- `RoutineHistoryUpdater` owns history catch-up and one ordered consumer of store
  snapshots. Notification reconciliation follows committed state, not unsaved edits.
- `NotificationsHandler` owns native local-notification requests. It awaits
  scheduling outcomes and reconciles pending reminders against current routines.
- `AppLockState` owns lock transitions and authentication attempt generations.
  `SceneDelegate` maps those states to an opaque blocker and native authentication.
  Returning to the foreground alone never unlocks protected content.

## Storage contracts

Local is the default contributor build. It uses Application Support SQLite with
no CloudKit configuration or owner signing requirement. Tests use isolated memory
or temporary SQLite stores.

Official Dev/Prod builds retain their existing bundle IDs, app groups and private
CloudKit containers. Production uses app group
`group.com.dm.routine.app.shared.prod`, container
`iCloud.com.dm.routine.app.icloud.prod`, and `Database/RoutineApp.sqlite` inside the
app group. Changing those identifiers or paths requires an explicit migration.

The managed object model is unchanged. Updates mutate existing objects so their
identities survive, and preserve stored history absent from a stale edit snapshot.
Automatic deletion of duplicate routine/history graphs has been removed. Existing
duplicates are retained rather than choosing which user data to discard.

CloudKit still requires Apple's push notification capability and remote-notification
background mode. Removing Firebase Messaging does not remove those capabilities
from official cloud builds.

## Privacy and integrations

There is no purchase entitlement, routine-count limit or telemetry identity.
All features are free. Firebase and RevenueCat are absent from the package graph.
Configuration and support links are static. Native StoreKit remains for review
requests, and CloudKit remains for official iCloud synchronization.

The app privacy manifest declares app-local UserDefaults access. See `PRIVACY.md`
for user-facing behavior and `THIRD_PARTY_NOTICES.md` for retained dependency licenses.

## Verification

Use the README commands with an explicitly owned simulator UDID. Tests cover free
feature access, lock transitions, reminder failures/ordering and persistence across
SQLite reopening. Synthetic fixtures are not proof of a signed production upgrade
or real two-device CloudKit convergence; verify those before release.
