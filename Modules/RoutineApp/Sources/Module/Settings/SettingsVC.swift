import UIKit

@MainActor protocol SettingsViewInterface: AnyObject {
  func update(with snapshot: Snapshot<Settings.Section, Settings.Row>)
  func showAlert(with viewModel: Alert.VM)
}

final class SettingsVC: UIViewController {
  // MARK: - Dependencies
  private let presenter: SettingsPresenter
  
  // MARK: - Private Properties
  private lazy var contentView = SettingsView()
  
  // MARK: - Init
  init(presenter: SettingsPresenter) {
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  override func loadView() {
    view = contentView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    presenter.viewDidLoad()
  }
}

// MARK: - SettingsViewInterface
extension SettingsVC: SettingsViewInterface {
  func update(with snapshot: Snapshot<Settings.Section, Settings.Row>) {
    contentView.update(with: snapshot)
  }
  
  func showAlert(with viewModel: Alert.VM) {
    Alert.show(on: self, with: viewModel)
  }
}

// MARK: - Private
extension SettingsVC {
  private func setupUI() {
    title = RoutineAppStrings.Settings.title
    contentView.onNotificationStateChangeRequest = { [weak self] in
      self?.presenter.notificationStateUpdateRequest($0)
    }
    contentView.onFaceIDStateChangeRequest = { [weak self] in
      self?.presenter.faceIDStateUpdateRequest($0)
    }
  }
}
