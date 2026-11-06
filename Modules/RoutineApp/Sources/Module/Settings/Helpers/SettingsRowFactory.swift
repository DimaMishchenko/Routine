import Foundation
import UIKit

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
  func supportRow(action: @escaping () -> Void) -> Settings.Row
  func acknowledgementsRow(action: @escaping () -> Void) -> Settings.Row
  func openSourceRow(action: @escaping () -> Void) -> Settings.Row
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
          icon: icon("globe", color: .systemBlue),
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
          icon: icon("bell.badge", color: .systemRed)
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
          icon: icon("icloud", color: .systemBlue),
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
          icon: icon("circle.lefthalf.filled", color: .systemIndigo),
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
          icon: icon("desktopcomputer", color: .systemCyan),
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
          icon: icon("ladybug", color: .systemOrange),
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
          icon: icon("star", color: .systemYellow),
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
          icon: icon("square.and.arrow.up", color: .systemBlue),
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
          icon: icon(biometryType == .faceID ? "faceid" : "touchid", color: .systemGreen)
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
          icon: icon("hand.raised", color: .systemIndigo),
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
          icon: icon("doc.text", color: .systemBrown),
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
          icon: icon("sparkles", color: .systemPurple),
          accessory: .disclosure
        )
      ),
      action: action
    )
  }
  
  func supportRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(
          title: String(localized: "support.title"),
          icon: icon("heart", color: .systemPink),
          accessory: .disclosure
        )
      ),
      action: action
    )
  }

  func acknowledgementsRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(
          title: RoutineAppStrings.Localizable.Settings.Row.acknowledgements,
          icon: icon("text.book.closed", color: .systemOrange),
          accessory: .disclosure
        )
      ),
      action: action
    )
  }

  func openSourceRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(
          title: RoutineAppStrings.Localizable.Settings.Row.openSource,
          icon: icon("chevron.left.forwardslash.chevron.right", color: .systemTeal),
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
          icon: icon("info.circle", color: .systemGray)
        )
      )
    )
  }

  private func icon(_ name: String, color: UIColor) -> UIImage? {
    let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
      .applying(UIImage.SymbolConfiguration.preferringMonochrome())
    return UIImage(systemName: name, withConfiguration: configuration)?
      .withTintColor(color, renderingMode: .alwaysOriginal)
  }
}
