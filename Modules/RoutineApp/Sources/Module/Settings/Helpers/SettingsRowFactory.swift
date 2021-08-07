import Foundation

protocol SettingsRowFactory {
  func languageRow(action: @escaping () -> Void) -> Settings.Row
  func reportBugRow(action: @escaping () -> Void) -> Settings.Row
  func suggestFeatureRow(action: @escaping () -> Void) -> Settings.Row
  func rateAppRow(action: @escaping () -> Void) -> Settings.Row
  func shareAppRow(action: @escaping () -> Void) -> Settings.Row
  func privacyPolicyRow(action: @escaping () -> Void) -> Settings.Row
  func termsOfUseRow(action: @escaping () -> Void) -> Settings.Row
  func appVersionRow() -> Settings.Row
}

final class SettingsRowFactoryImpl: SettingsRowFactory {
  // MARK: - Public
  func languageRow(action: @escaping () -> Void) -> Settings.Row {
    let code = Locale.preferredLanguages.first ?? .empty
    
    return .init(
      .value(
        .init(
          title: RoutineStrings.Settings.Row.language,
          value: Locale.current.localizedString(forLanguageCode: code)?.capitalized,
          accessory: .disclosure
        )
      ),
      action: action
    )
  }
  
  func reportBugRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(title: RoutineStrings.Settings.Row.reportBug, accessory: .disclosure)
      ),
      action: action
    )
  }
  
  func suggestFeatureRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(title: RoutineStrings.Settings.Row.suggestFeature, accessory: .disclosure)
      ),
      action: action
    )
  }
  
  func rateAppRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(title: RoutineStrings.Settings.Row.rateApp, accessory: .disclosure)
      ),
      action: action
    )
  }
  
  func shareAppRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(title: RoutineStrings.Settings.Row.shareApp, accessory: .disclosure)
      ),
      action: action
    )
  }
  
  func privacyPolicyRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(title: RoutineStrings.Settings.Row.privacyPolicy, accessory: .disclosure)
      ),
      action: action
    )
  }
  
  func termsOfUseRow(action: @escaping () -> Void) -> Settings.Row {
    .init(
      .value(
        .init(title: RoutineStrings.Settings.Row.termsOfUse, accessory: .disclosure)
      ),
      action: action
    )
  }
  
  func appVersionRow() -> Settings.Row {
    .init(
      .value(
        .init(
          title: RoutineStrings.Settings.Row.appVersion,
          value: AppInfo.appVersion,
          valueStyle: .bold
        )
      )
    )
  }
}
