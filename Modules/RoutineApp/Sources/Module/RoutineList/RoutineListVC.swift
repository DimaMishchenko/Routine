import UIKit

protocol RoutineListViewInterface: AnyObject {
  func update(
    with snapshot: Snapshot<RoutineList.Section, OutlineItem<RoutineList.Header, RoutineList.Row>>,
    animated: Bool
  )
  func showConfetti(with emoji: String)
  func showAlert(with viewModel: Alert.VM)
  func animateProgressUpdate(for viewModel: RoutineCellVM, at indexPath: IndexPath, completion: @escaping () -> Void)
}

final class RoutineListVC: UIViewController {
  var onSettings: (() -> Void)?
  private let presenter: RoutineListPresenter
  private lazy var contentView = RoutineListView()
  init(presenter: RoutineListPresenter) {
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
  private func setupUI() {
    navigationItem.title = {
      if Locale.current.languageCode == "uk" {
        return RoutineAppStrings.Localizable.RoutineList.title + " 🇺🇦"
      } else {
        return RoutineAppStrings.Localizable.RoutineList.title
      }
    }()
    let settingsButton = UIBarButtonItem(
      image: UIImage(systemName: "gearshape"),
      style: .plain,
      target: self,
      action: #selector(showSettings)
    )
    settingsButton.accessibilityLabel = RoutineAppStrings.Localizable.Settings.title
    settingsButton.accessibilityIdentifier = "routineList.settings"
    navigationItem.leftBarButtonItem = settingsButton

    let addButton: UIBarButtonItem
    #if targetEnvironment(macCatalyst)
    let button = UIButton(type: .custom)
    button.setImage(UIImage(systemName: "plus"), for: .normal)
    button.tintColor = .white
    button.backgroundColor = .systemBlue
    button.layer.cornerRadius = 18
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      button.widthAnchor.constraint(equalToConstant: 36),
      button.heightAnchor.constraint(equalToConstant: 36)
    ])
    button.accessibilityLabel = RoutineAppStrings.Localizable.RoutineList.add
    button.accessibilityIdentifier = "routineList.add"
    button.addTarget(self, action: #selector(addRoutine), for: .touchUpInside)
    addButton = UIBarButtonItem(customView: button)
    #else
    addButton = UIBarButtonItem(
      image: UIImage(systemName: "plus"),
      style: .prominent,
      target: self,
      action: #selector(addRoutine)
    )
    #endif
    addButton.tintColor = .systemBlue
    addButton.accessibilityLabel = RoutineAppStrings.Localizable.RoutineList.add
    addButton.accessibilityIdentifier = "routineList.add"
    navigationItem.rightBarButtonItem = addButton

    contentView.onEdit = { [weak self] in self?.presenter.editRoutine(at: $0, rowIndex: $1) }
    contentView.onDelete = { [weak self] in self?.presenter.deleteRoutine(at: $0, rowIndex: $1) }
    contentView.onIncreaseProgress = { [weak self] in self?.presenter.increaseProgress(at: $0, rowIndex: $1) }
    contentView.onDecreaseProgress = { [weak self] in self?.presenter.decreaseProgress(at: $0, rowIndex: $1) }
  }

  @objc private func showSettings() {
    onSettings?()
  }

  @objc private func addRoutine() {
    presenter.addRoutine()
  }
}
extension RoutineListVC: RoutineListViewInterface {
  func update(
    with snapshot: Snapshot<RoutineList.Section, OutlineItem<RoutineList.Header, RoutineList.Row>>,
    animated: Bool
  ) {
    contentView.update(with: snapshot, animated: animated)
  }
  
  func showConfetti(with emoji: String) {
    Confetti.run(with: emoji)
    HapticFeedback.success()
  }
  
  func showAlert(with viewModel: Alert.VM) {
    Alert.show(on: self, with: viewModel)
  }
  
  func animateProgressUpdate(for viewModel: RoutineCellVM, at indexPath: IndexPath, completion: @escaping () -> Void) {
    contentView.animateProgressUpdate(for: viewModel, at: indexPath, completion: completion)
  }
}
