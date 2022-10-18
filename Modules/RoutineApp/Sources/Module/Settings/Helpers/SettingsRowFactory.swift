import Foundation

protocol SettingsRowFactory {
  func languageRow(action: @escaping () -> Void) -> Settings.Row
  func notificationsRow(isAuthorized: Bool) -> Settings.Row
  func appearanceRow(action: @escaping () -> Void) -> Settings.Row
  func reportBugRow(action: @escaping () -> Void) -> Settings.Row
  func writeReviewRow(action: @escaping () -> Void) -> Settings.Row
  func shareAppRow(action: @escaping () -> Void) -> Settings.Row
  func termsPolicy(action: @escaping () -> Void) -> Settings.Row
  func onboardingRow(action: @escaping () -> Void) -> Settings.Row
  func appVersionRow(action: @escaping () -> Void) -> Settings.Row
}

final class SettingsRowFactoryImpl: SettingsRowFactory {
  // MARK: - Public
  func languageRow(action: @escaping () -> Void) -> Settings.Row {
    let code = Locale.preferredLanguages.first ?? .empty
    
    return .init(
      .value(
        .init(
          title: RoutineAppStrings.Settings.Row.language,
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
          title: RoutineAppStrings.Settings.Row.notifications,
          state: isAuthorized,
          icon: RoutineAppAsset.Icon.notification.image
        )
      )
    )
  }
  
  func appearanceRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(
          title: RoutineAppStrings.Settings.Row.appearance,
          icon: RoutineAppAsset.Icon.appearance.image,
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
          title: RoutineAppStrings.Settings.Row.reportBug,
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
          title: RoutineAppStrings.Settings.Row.writeReview,
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
          title: RoutineAppStrings.Settings.Row.shareApp,
          icon: RoutineAppAsset.Icon.share.image,
          accessory: .disclosure
        )
      ),
      action: action
    )
  }
  
  func termsPolicy(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(
          title: RoutineAppStrings.Settings.Row.termsPolicy,
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
          title: RoutineAppStrings.Settings.Row.onboarding,
          icon: RoutineAppAsset.Icon.onboarding.image
        )
      ),
      action: action
    )
  }
  
  func appVersionRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(
          title: RoutineAppStrings.Settings.Row.appVersion,
          value: .text(AppInfo.appVersion, style: .bold),
          icon: RoutineAppAsset.Icon.appversion.image
        )
      ),
      action: action
    )
  }
}
