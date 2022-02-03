import UIKit

protocol RoutineListViewInterface: AnyObject {
  func update(
    with snapshot: Snapshot<RoutineList.Section, OutlineItem<RoutineList.Header, RoutineList.Row>>,
    animated: Bool
  )
}

final class RoutineListVC: UIViewController {
  // MARK: - Dependencies
  private let presenter: RoutineListPresenter
  
  // MARK: - Private Properties
  private lazy var contentView = RoutineListView()
  
  // MARK: - Init
  init(presenter: RoutineListPresenter) {
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
  
  // MARK: - Private
  private func setupUI() {
    title = RoutineAppStrings.RoutineList.title
    contentView.onAdd = { [weak self] in self?.presenter.addRoutine() }
    contentView.onEdit = { [weak self] in self?.presenter.editRoutine(at: $0, rowIndex: $1) }
    contentView.onDelete = { [weak self] in self?.presenter.deleteRoutine(at: $0, rowIndex: $1) }
    contentView.onIncreaseProgress = { [weak self] in self?.presenter.increaseProgress(at: $0, rowIndex: $1) }
    contentView.onDecreaseProgress = { [weak self] in self?.presenter.decreaseProgress(at: $0, rowIndex: $1) }
  }
}

// MARK: - RoutineListViewInterface
extension RoutineListVC: RoutineListViewInterface {
  func update(
    with snapshot: Snapshot<RoutineList.Section, OutlineItem<RoutineList.Header, RoutineList.Row>>,
    animated: Bool
  ) {
    contentView.update(with: snapshot, animated: animated)
  }
}
