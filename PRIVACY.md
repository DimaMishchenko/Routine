# Privacy

This policy describes the open-source version in this repository. Older App Store
builds may have different behavior and integrations.

Routine stores routines, progress, history and reminder settings on your device.
The default Local build uses local storage. Official signed Dev/Prod builds can
sync that information through Apple's CloudKit using your iCloud account. Apple's
iCloud and device backup settings govern those services. Routine does not operate
a separate account or synchronization server.

Reminders use local notifications with your permission. Face ID, Touch ID or device
passcode authentication is handled by the operating system; Routine does not receive
biometric templates. Notification and authentication permissions can be changed in
system settings.

This version does not include Firebase analytics, crash reporting, remote config,
remote push messaging, RevenueCat, purchases, a paywall, or a generated analytics
user identifier. It does not send routine data to those services. Local diagnostic
logs may be produced by the app and operating system.

If you choose to contact support by email, the draft contains the date, device model,
iOS version and app version to help diagnose the issue. Review or remove that text
before sending. Email, GitHub and App Store links open external services
only when you choose them; their own privacy policies apply. Do not put private
routine information into public GitHub issues.

Deleting Routine does not guarantee removal of every copy of your data. On
iPhone and iPad, deleting the app normally removes its app-local data. On Mac,
removing the app can leave local app-container and shared App Group data behind.
CloudKit data and iCloud backups may also remain under your Apple account; manage
these separately through Apple’s iCloud storage settings. Contact support if you
need help identifying stored Routine data before removing it. See
[Apple’s Mac uninstall guidance](https://support.apple.com/en-us/102610).

For privacy questions contact dimasike.dev@gmail.com.

The app privacy manifest declares no tracking domains or developer-collected data.
It declares UserDefaults access with reason `CA92.1` solely for app-local preferences
such as appearance, onboarding and the authentication setting. The app does not
use file-timestamp, available-disk-space, system-boot-time or active-keyboard APIs.
SDK manifests ship separately with DGCharts 5.1.0 and SnapKit 5.7.1; the app's
manifest does not replace them. Recheck the built archive and current App Store
privacy answers before release.

Declaration references: [Apple's approved API reasons](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype)
and [third-party SDK requirements](https://developer.apple.com/support/third-party-SDK-requirements/).
