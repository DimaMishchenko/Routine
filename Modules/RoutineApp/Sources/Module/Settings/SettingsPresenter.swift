import Combine
import Foundation

protocol SettingsPresenter: AnyObject {
  func viewDidLoad()
  func notificationStateUpdateRequest(_ currentStatus: Bool)
  func faceIDStateUpdateRequest(_ currentStatus: Bool)
}

final class SettingsPresenterImpl: SettingsPresenter {
  // MARK: - Dependencies
  weak var view: SettingsViewInterface?
  private let rowFactory: SettingsRowFactory
  private let appStateObserver: AppStateObserver
  private let notificationsHandler: NotificationsHandler
  private let identifierCopyHandler: UserIdentifierCopyHandler
  private let authenticator: Authenticator
  private let inAppPurchases: InAppPurchases
  
  // MARK: - Properties
  var premium: (() -> Void)?
  var openSettings: (() -> Void)?
  var mailSupport: ((String, String) -> Void)?
  var telegramSupport: (() -> Void)?
  var rateApp: (() -> Void)?
  var share: (() -> Void)?
  var openCloudInfo: (() -> Void)?
  var openAppearance: (() -> Void)?
  var openTutorial: (() -> Void)?
  var openMacApp: (() -> Void)?
  
  // MARK: - Private Properties
  @Defaults(key: .useFaceID, initial: false) private var useFaceID: Bool
  private var cancellables: Set<AnyCancellable> = []
  
  // MARK: - Init
  init(
    rowFactory: SettingsRowFactory,
    appStateObserver: AppStateObserver,
    notificationsHandler: NotificationsHandler,
    identifierCopyHandler: UserIdentifierCopyHandler,
    authenticator: Authenticator,
    inAppPurchases: InAppPurchases
  ) {
    self.rowFactory = rowFactory
    self.appStateObserver = appStateObserver
    self.notificationsHandler = notificationsHandler
    self.identifierCopyHandler = identifierCopyHandler
    self.authenticator = authenticator
    self.inAppPurchases = inAppPurchases

    setupAppStateObserver()
    disableFaceIDIfNeeded()
    setupPremiumObserver()
  }
  
  // MARK: - SettingsPresenter
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
    guard inAppPurchases.subscribed else {
      useFaceID = false
      premium?()
      return
    }
    
    Task(priority: .userInitiated) {
      if currentStatus {
        useFaceID = false
      } else if authenticator.biometryType == .none && !authenticator.isLockout() {
        useFaceID = false
        await view?.showAlert(with: failedToUseFaceIDAlert())
      } else {
        useFaceID = await authenticator.auth(biometryOnly: true)
      }
      Analytics.send(.biometrics, parameters: [.biometricsEnabled: useFaceID])
      await reloadSnapshot()
    }
  }
  
  // MARK: - Private
  private func setupAppStateObserver() {
    appStateObserver
      .on(.didBecomeActive)
      .sink { [weak self] in
        guard let self = self else { return }
        self.disableFaceIDIfNeeded()
        Task { await self.reloadSnapshot() }
      }
      .store(in: &cancellables)
  }
  
  private func disableFaceIDIfNeeded() {
    if self.authenticator.biometryType == .none {
      self.useFaceID = false
    }
  }
  
  private func setupPremiumObserver() {
    inAppPurchases.$subscribed
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        Task { [self] in await self?.reloadSnapshot() }
      }
      .store(in: &cancellables)
  }
  
  // swiftlint:disable:next function_body_length
  private func reloadSnapshot() async {
    typealias Item = Snapshot<Settings.Section?, Settings.Row>.Item
    
    let isAuthorized = await notificationsHandler.isAuthorized()
    
    await view?.update(
      with: Snapshot {
        if !inAppPurchases.subscribed {
          Item(
            section: nil,
            rows: [
              .init(.premium(.init(accesory: .disclosure))) { [weak self] in
                self?.premium?()
              }
            ]
          )          
        }
        
        Item(
          section: .init(model: .init(title: RoutineAppStrings.Settings.Section.app)),
          rows: [
            rowFactory.languageRow { [weak self] in
              guard let self = self else { return }
              Task(priority: .userInitiated) {
                await self.view?.showAlert(with: self.languageAlertVM())
              }
            },
            rowFactory.notificationsRow(isAuthorized: isAuthorized),
            rowFactory.iCloudSyncRow { [weak self] in self?.openCloudInfo?() },
            rowFactory.premiumRow { [weak self] in self?.premium?() },
            rowFactory.appearanceRow { [weak self] in self?.openAppearance?() }
          ]
        )
        
        #if !targetEnvironment(macCatalyst)
        Item(
          section: .init(model: .init(title: RoutineAppStrings.Settings.Section.macApp)),
          rows: [
            rowFactory.macRow { [weak self] in self?.openMacApp?() }
          ]
        )
        #endif
        
        Item(
          section: .init(model: .init(title: RoutineAppStrings.Settings.Section.feedback)),
          rows: [
            rowFactory.reportBugRow { [weak self] in
              guard let self = self else { return }
              Task(priority: .userInitiated) {
                await self.view?.showAlert(
                  with: self.feedbackAlertVM(
                    title: RoutineAppStrings.Settings.Alert.ReportBug.title,
                    message: RoutineAppStrings.Settings.Alert.ReportBug.message,
                    mailConfig: (
                      subject: RoutineAppStrings.Settings.Mail.ReportBug.subject,
                      message: RoutineAppStrings.Settings.Mail.ReportBug.message
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
          section: .init(model: .init(title: RoutineAppStrings.Settings.Section.security)),
          rows: [
            rowFactory.faceID(biometryType: authenticator.biometryType, isEnabled: useFaceID)
          ]
        )

        Item(
          section: .init(model: .init(title: RoutineAppStrings.Settings.Section.more)),
          rows: [
            rowFactory.termsPolicy {},
            rowFactory.onboardingRow { [weak self] in
              self?.openTutorial?()
            },
            rowFactory.appVersionRow { [weak self] in
              self?.identifierCopyHandler.appVersionSelected()
            }
          ]
        )
      }
    )
  }
  
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
  
  private func notificationSettingsAlertVM(enabled: Bool) -> Alert.VM {
    let title = enabled ?
    RoutineAppStrings.Settings.Alert.Notifications.Title.disable :
    RoutineAppStrings.Settings.Alert.Notifications.Title.enable
    
    return .init(
      title: title,
      message: RoutineAppStrings.Settings.Alert.Notifications.message,
      actions: [
        .custom(.init(title: RoutineAppStrings.Settings.Alert.Button.openSettings, style: .default)),
        .cancel
      ]
    ) { [weak self] in
      guard case .custom = $0 else { return }
      self?.openSettings?()
    }
  }
  
  private func failedToUseFaceIDAlert() -> Alert.VM {
    .init(
      title: RoutineAppStrings.Settings.Alert.FailedFaceID.title,
      message: RoutineAppStrings.Settings.Alert.FailedFaceID.message,
      actions: [
        .custom(.init(title: RoutineAppStrings.Settings.Alert.Button.openSettings, style: .default)),
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
