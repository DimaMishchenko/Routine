import UIKit

@MainActor protocol SettingsViewInterface: AnyObject {
  func update(with snapshot: Snapshot<Settings.Section?, Settings.Row>)
  func showAlert(with viewModel: Alert.VM)
}

final class SettingsVC: UIViewController, NavigationContentLayout {
  var navigationContentInset: CGFloat { 20 }
  private let presenter: SettingsPresenter
  
  private lazy var contentView = SettingsView()
  
  init(presenter: SettingsPresenter) {
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    view = contentView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    presenter.viewDidLoad()
  }
}

extension SettingsVC: SettingsViewInterface {
  func update(with snapshot: Snapshot<Settings.Section?, Settings.Row>) {
    contentView.update(with: snapshot)
  }
  
  func showAlert(with viewModel: Alert.VM) {
    Alert.show(on: self, with: viewModel)
  }
}

extension SettingsVC {
  private func setupUI() {
    title = RoutineAppStrings.Localizable.Settings.title
    contentView.onNotificationStateChangeRequest = { [weak self] in
      self?.presenter.notificationStateUpdateRequest($0)
    }
    contentView.onFaceIDStateChangeRequest = { [weak self] in
      self?.presenter.faceIDStateUpdateRequest($0)
    }
  }
}
