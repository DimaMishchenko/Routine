import Foundation
import UIKit.UIImage

protocol SettingsRowFactory {
  func languageRow(action: @escaping () -> Void) -> Settings.Row
  func notificationsRow(isAuthorized: Bool) -> Settings.Row
  func iCloudSyncRow(action: @escaping () -> Void) -> Settings.Row
  func appearanceRow(action: @escaping () -> Void) -> Settings.Row
  func macRow(action: @escaping () -> Void) -> Settings.Row
  func reportBugRow(action: @escaping () -> Void) -> Settings.Row
  func writeReviewRow(action: @escaping () -> Void) -> Settings.Row
  func shareAppRow(action: @escaping () -> Void) -> Settings.Row
  func faceID(biometryType: BiometryType, isEnabled: Bool) -> Settings.Row
  func privacyPolicy(action: @escaping () -> Void) -> Settings.Row
  func termsOfUse(action: @escaping () -> Void) -> Settings.Row
  func onboardingRow(action: @escaping () -> Void) -> Settings.Row
  func authorRow(name: String, url: URL?, action: @escaping (URL) -> Void) -> Settings.Row
  func acknowledgementsRow(action: @escaping () -> Void) -> Settings.Row
  func appVersionRow() -> Settings.Row
}

final class SettingsRowFactoryImpl: SettingsRowFactory {
  func languageRow(action: @escaping () -> Void) -> Settings.Row {
    let code = Locale.preferredLanguages.first ?? .empty
    
    return .init(
      .value(
        .init(
          title: RoutineAppStrings.Localizable.Settings.Row.language,
          value: .text(Locale.current.localizedString(forLanguageCode: code)?.capitalized),
          icon: RoutineAppAsset.Icon.language.image,
          accessory: .disclosure
        )
      ),
      action: action
    )
  }
  
  func notificationsRow(isAuthorized: Bool) -> Settings.Row {
    .init(
      .switch(
        .init(
          title: RoutineAppStrings.Localizable.Settings.Row.notifications,
          state: isAuthorized,
          icon: RoutineAppAsset.Icon.notification.image
        ),
        .notifications
      )
    )
  }
  
  func iCloudSyncRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(
          title: RoutineAppStrings.Localizable.Settings.Row.iCloudSync,
          icon: RoutineAppAsset.Icon.iCloud.image,
          accessory: .disclosure
        )
      ),
      action: action
    )
  }
  
  func appearanceRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(
          title: RoutineAppStrings.Localizable.Settings.Row.appearance,
          icon: RoutineAppAsset.Icon.appearance.image,
          accessory: .disclosure
        )
      ),
      action: action
    )
  }
  
  func macRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(
          title: RoutineAppStrings.Localizable.Settings.Row.macOS,
          icon: RoutineAppAsset.Icon.macApp.image,
          accessory: .disclosure
        )
      ),
      action: action
    )
  }
  
  func reportBugRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(
          title: RoutineAppStrings.Localizable.Settings.Row.reportBug,
          icon: RoutineAppAsset.Icon.report.image,
          accessory: .disclosure
        )
      ),
      action: action
    )
  }
  
  func writeReviewRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(
          title: RoutineAppStrings.Localizable.Settings.Row.writeReview,
          icon: RoutineAppAsset.Icon.review.image,
          accessory: .disclosure
        )
      ),
      action: action
    )
  }
  
  func shareAppRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(
          title: RoutineAppStrings.Localizable.Settings.Row.shareApp,
          icon: RoutineAppAsset.Icon.share.image,
          accessory: .disclosure
        )
      ),
      action: action
    )
  }
  
  func faceID(biometryType: BiometryType, isEnabled: Bool) -> Settings.Row {
    .init(
      .switch(
        .init(
          title: biometryType == .faceID ?
            RoutineAppStrings.Localizable.Settings.Row.faceID :
            RoutineAppStrings.Localizable.Settings.Row.touchID,
          state: isEnabled,
          icon: RoutineAppAsset.Icon.faceID.image
        ),
        .faceID
      )
    )
  }
  
  func privacyPolicy(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(
          title: RoutineAppStrings.Localizable.Settings.Row.privacyPolicy,
          icon: RoutineAppAsset.Icon.terms.image,
          accessory: .disclosure
        )
      ),
      action: action
    )
  }
  
  func termsOfUse(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(
          title: RoutineAppStrings.Localizable.Settings.Row.termsOfUse,
          icon: RoutineAppAsset.Icon.terms.image,
          accessory: .disclosure
        )
      ),
      action: action
    )
  }
  
  func onboardingRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(
          title: RoutineAppStrings.Localizable.Settings.Row.onboarding,
          icon: RoutineAppAsset.Icon.onboarding.image
        )
      ),
      action: action
    )
  }
  
  func authorRow(name: String, url: URL?, action: @escaping (URL) -> Void) -> Settings.Row {
    .init(
      .value(
        .init(
          title: name,
          value: .text(url?.lastPathComponent),
          icon: UIImage(systemName: "person.crop.circle"),
          accessory: url == nil ? .none : .disclosure
        )
      ),
      action: url.map { url in { action(url) } }
    )
  }

  func acknowledgementsRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(
          title: RoutineAppStrings.Localizable.Settings.Row.acknowledgements,
          icon: RoutineAppAsset.Icon.terms.image,
          accessory: .disclosure
        )
      ),
      action: action
    )
  }

  func appVersionRow() -> Settings.Row {
    .init(
      .value(
        .init(
          title: RoutineAppStrings.Localizable.Settings.Row.appVersion,
          value: .text(AppInfo.appVersion, style: .bold),
          icon: RoutineAppAsset.Icon.appversion.image
        )
      )
    )
  }
}
