import Combine
import Foundation

protocol SettingsPresenter: AnyObject {
  func viewDidLoad()
  func notificationStateUpdateRequest(_ currentStatus: Bool)
  func faceIDStateUpdateRequest(_ currentStatus: Bool)
}

final class SettingsPresenterImpl: SettingsPresenter {
  weak var view: SettingsViewInterface?
  private let rowFactory: SettingsRowFactory
  private let appStateObserver: AppStateObserver
  private let notificationsHandler: NotificationsHandler
  private let authenticator: Authenticator
  var openSettings: (() -> Void)?
  var mailSupport: ((String, String) -> Void)?
  var githubSupport: (() -> Void)?
  var rateApp: (() -> Void)?
  var share: (() -> Void)?
  var openCloudInfo: (() -> Void)?
  var openAppearance: (() -> Void)?
  var openTutorial: (() -> Void)?
  var openMacApp: (() -> Void)?
  var privacyPolicy: (() -> Void)?
  var termsOfUse: (() -> Void)?
  @Defaults(key: .useFaceID, initial: false) private var useFaceID: Bool
  private var cancellables: Set<AnyCancellable> = []
  init(
    rowFactory: SettingsRowFactory,
    appStateObserver: AppStateObserver,
    notificationsHandler: NotificationsHandler,
    authenticator: Authenticator
  ) {
    self.rowFactory = rowFactory
    self.appStateObserver = appStateObserver
    self.notificationsHandler = notificationsHandler
    self.authenticator = authenticator

    setupAppStateObserver()
  }
  func viewDidLoad() {
    Task(priority: .userInitiated) {
      await reloadSnapshot()
    }
  }
  
  func notificationStateUpdateRequest(_ currentStatus: Bool) {
    Task(priority: .userInitiated) {
      if currentStatus {
        await view?.showAlert(with: notificationSettingsAlertVM(enabled: true))
      } else {
        let result = await notificationsHandler.request()
        if !result {
          await view?.showAlert(with: notificationSettingsAlertVM(enabled: false))
        }
      }
      await reloadSnapshot()
    }
  }
  
  func faceIDStateUpdateRequest(_ currentStatus: Bool) {
    Task(priority: .userInitiated) {
      if currentStatus {
        useFaceID = false
      } else if authenticator.biometryType == .none && !authenticator.isLockout() {
        useFaceID = false
        await view?.showAlert(with: failedToUseFaceIDAlert())
      } else {
        useFaceID = await authenticator.auth(biometryOnly: true)
      }
      await reloadSnapshot()
    }
  }
  private func setupAppStateObserver() {
    appStateObserver
      .on(.didBecomeActive)
      .sink { [weak self] in
        guard let self = self else { return }
        Task { await self.reloadSnapshot() }
      }
      .store(in: &cancellables)
  }
  
  // swiftlint:disable:next function_body_length
  private func reloadSnapshot() async {
    typealias Item = Snapshot<Settings.Section?, Settings.Row>.Item
    
    let isAuthorized = await notificationsHandler.isAuthorized()
    
    await view?.update(
      with: Snapshot {
        Item(
          section: .init(model: .init(title: RoutineAppStrings.Localizable.Settings.Section.app)),
          rows: {
            var rows = [
              rowFactory.notificationsRow(isAuthorized: isAuthorized),
              rowFactory.appearanceRow { [weak self] in self?.openAppearance?() }
            ]
            
            if Environment.current != .local {
              rows.insert(rowFactory.iCloudSyncRow { [weak self] in self?.openCloudInfo?() }, at: 1)
            }

            #if !targetEnvironment(macCatalyst)
            rows.insert(
              rowFactory.languageRow { [weak self] in
                guard let self = self else { return }
                Task(priority: .userInitiated) {
                  await self.view?.showAlert(with: self.languageAlertVM())
                }
              },
              at: .zero
            )
            #endif
            
            return rows
          }()
        )
        
        #if !targetEnvironment(macCatalyst)
        Item(
          section: .init(model: .init(title: RoutineAppStrings.Localizable.Settings.Section.macApp)),
          rows: [
            rowFactory.macRow { [weak self] in self?.openMacApp?() }
          ]
        )
        #endif
        
        Item(
          section: .init(model: .init(title: RoutineAppStrings.Localizable.Settings.Section.feedback)),
          rows: [
            rowFactory.reportBugRow { [weak self] in
              guard let self = self else { return }
              Task(priority: .userInitiated) {
                await self.view?.showAlert(
                  with: self.feedbackAlertVM(
                    title: RoutineAppStrings.Localizable.Settings.Alert.ReportBug.title,
                    message: RoutineAppStrings.Localizable.Settings.Alert.ReportBug.message,
                    mailConfig: (
                      subject: RoutineAppStrings.Localizable.Settings.Mail.ReportBug.subject,
                      message: RoutineAppStrings.Localizable.Settings.Mail.ReportBug.message
                    )
                  )
                )
              }
            },
            rowFactory.writeReviewRow { [weak self] in self?.rateApp?() },
            rowFactory.shareAppRow { [weak self] in self?.share?() }
          ]
        )
        
        Item(
          section: .init(model: .init(title: RoutineAppStrings.Localizable.Settings.Section.security)),
          rows: [
            rowFactory.faceID(biometryType: authenticator.biometryType, isEnabled: useFaceID)
          ]
        )

        Item(
          section: .init(model: .init(title: RoutineAppStrings.Localizable.Settings.Section.more)),
          rows: [
            rowFactory.privacyPolicy { [weak self] in self?.privacyPolicy?() },
            rowFactory.termsOfUse { [weak self] in self?.termsOfUse?() },
            rowFactory.onboardingRow { [weak self] in self?.openTutorial?() },
            rowFactory.appVersionRow()
          ]
        )
      }
    )
  }
  
  private func languageAlertVM() -> Alert.VM {
    let continueAction = Alert.ActionType.Custom(
      title: RoutineAppStrings.Localizable.Settings.Alert.Language.Button.continue,
      style: .default
    )
    
    return .init(
      title: RoutineAppStrings.Localizable.Settings.Alert.Language.title,
      message: RoutineAppStrings.Localizable.Settings.Alert.Language.message,
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
      title: RoutineAppStrings.Localizable.Common.email,
      style: .default
    )
    let githubAction = Alert.ActionType.Custom(
      title: RoutineAppStrings.Localizable.Common.github,
      style: .default
    )
    
    return .init(
      title: title,
      message: message,
      actions: [.custom(emailAction), .custom(githubAction), .cancel]
    ) { [weak self] in
      guard case .custom(let action) = $0 else { return }
      switch action {
      case emailAction: self?.mailSupport?(mailConfig.subject, mailConfig.message)
      case githubAction: self?.githubSupport?()
      default: return
      }
    }
  }
  
  private func notificationSettingsAlertVM(enabled: Bool) -> Alert.VM {
    let title = enabled ?
    RoutineAppStrings.Localizable.Settings.Alert.Notifications.Title.disable :
    RoutineAppStrings.Localizable.Settings.Alert.Notifications.Title.enable
    
    return .init(
      title: title,
      message: RoutineAppStrings.Localizable.Settings.Alert.Notifications.message,
      actions: [
        .custom(.init(title: RoutineAppStrings.Localizable.Settings.Alert.Button.openSettings, style: .default)),
        .cancel
      ]
    ) { [weak self] in
      guard case .custom = $0 else { return }
      self?.openSettings?()
    }
  }
  
  private func failedToUseFaceIDAlert() -> Alert.VM {
    .init(
      title: RoutineAppStrings.Localizable.Settings.Alert.FailedFaceID.title,
      message: RoutineAppStrings.Localizable.Settings.Alert.FailedFaceID.message,
      actions: [
        .custom(.init(title: RoutineAppStrings.Localizable.Settings.Alert.Button.openSettings, style: .default)),
        .cancel
      ]
    ) { [weak self] in
      guard case .custom = $0 else { return }
      self?.openSettings?()
    }
  }
}

extension DefaultsKey {
  static let useFaceID: DefaultsKey = "use.faceid"
}
