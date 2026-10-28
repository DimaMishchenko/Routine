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
    contentView.onAdd = { [weak self] in self?.presenter.addRoutine() }
    contentView.onEdit = { [weak self] in self?.presenter.editRoutine(at: $0, rowIndex: $1) }
    contentView.onDelete = { [weak self] in self?.presenter.deleteRoutine(at: $0, rowIndex: $1) }
    contentView.onIncreaseProgress = { [weak self] in self?.presenter.increaseProgress(at: $0, rowIndex: $1) }
    contentView.onDecreaseProgress = { [weak self] in self?.presenter.decreaseProgress(at: $0, rowIndex: $1) }
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
