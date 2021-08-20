import Foundation

protocol SettingsPresenter: AnyObject {
  func viewDidLoad()
}

final class SettingsPresenterImpl: SettingsPresenter {
  // MARK: - Dependencies
  weak var view: SettingsViewInterface?
  private let rowFactory: SettingsRowFactory
  
  // MARK: - Properties
  var openSettings: (() -> Void)?
  var mailSupport: ((String, String) -> Void)?
  var telegramSupport: (() -> Void)?
  var rateApp: (() -> Void)?
  var share: (() -> Void)?
  
  // MARK: - Init
  init(rowFactory: SettingsRowFactory) {
    self.rowFactory = rowFactory
  }
  
  // MARK: - SettingsPresenter
  func viewDidLoad() {
    view?.update(
      with: Snapshot(
        items: [
          .init(
            section: .init(model: .init(title: RoutineAppStrings.Settings.Section.app)),
            rows: [
              rowFactory.languageRow { [weak self] in
                guard let self = self else { return }
                self.view?.showAlert(with: self.languageAlertVM())
              }
            ]
          ),
          .init(
            section: .init(model: .init(title: RoutineAppStrings.Settings.Section.feedback)),
            rows: [
              rowFactory.reportBugRow { [weak self] in
                guard let self = self else { return }
                self.view?.showAlert(
                  with: self.feedbackAlertVM(
                    title: RoutineAppStrings.Settings.Alert.ReportBug.title,
                    message: RoutineAppStrings.Settings.Alert.ReportBug.message,
                    mailConfig: (
                      subject: RoutineAppStrings.Settings.Mail.ReportBug.subject,
                      message: RoutineAppStrings.Settings.Mail.ReportBug.message
                    )
                  )
                )
              },
              rowFactory.suggestFeatureRow { [weak self] in
                guard let self = self else { return }
                self.view?.showAlert(
                  with: self.feedbackAlertVM(
                    title: RoutineAppStrings.Settings.Alert.SuggestFeature.title,
                    message: RoutineAppStrings.Settings.Alert.SuggestFeature.message,
                    mailConfig: (
                      subject: RoutineAppStrings.Settings.Mail.SuggestFeature.subject,
                      message: RoutineAppStrings.Settings.Mail.SuggestFeature.message
                    )
                  )
                )
              },
              rowFactory.rateAppRow { [weak self] in self?.rateApp?() },
              rowFactory.shareAppRow { [weak self] in self?.share?() }
            ]
          ),
          .init(
            section: .init(model: .init(title: RoutineAppStrings.Settings.Section.more)),
            rows: [
              rowFactory.privacyPolicyRow {},
              rowFactory.termsOfUseRow {},
              rowFactory.appVersionRow()
            ]
          )
        ]
      )
    )
  }
  
  // MARK: - Private
  private func languageAlertVM() -> Alert.VM {
    let continueAction = Alert.ActionType.Custom(
      title: RoutineAppStrings.Settings.Alert.Language.Button.continue,
      style: .default
    )
    
    return .init(
      title: RoutineAppStrings.Settings.Alert.Language.title,
      message: RoutineAppStrings.Settings.Alert.Language.message,
      actions: [
        .custom(continueAction),
        .cancel
      ]
    ) { [weak self] in
      guard case .custom(let action) = $0, action == continueAction else { return }
      self?.openSettings?()
    }
  }
  
  private func feedbackAlertVM(
    title: String,
    message: String,
    mailConfig: (subject: String, message: String)
  ) -> Alert.VM {
    let emailAction = Alert.ActionType.Custom(
      title: RoutineAppStrings.Common.email,
      style: .default
    )
    let telegramAction = Alert.ActionType.Custom(
      title: RoutineAppStrings.Common.telegram,
      style: .default
    )
    
    return .init(
      title: title,
      message: message,
      actions: [.custom(emailAction), .custom(telegramAction), .cancel]
    ) { [weak self] in
      guard case .custom(let action) = $0 else { return }
      switch action {
      case emailAction: self?.mailSupport?(mailConfig.subject, mailConfig.message)
      case telegramAction: self?.telegramSupport?()
      default: return
      }
    }
  }
}
