import UIKit

protocol RoutineEditViewInterface: AnyObject {
  func update(title: String)
  func updateDelete(visibility isVisible: Bool)
  func update(with snapshot: Snapshot<RoutineEdit.Section, RoutineEdit.Row>)
  func showAlert(with viewModel: Alert.VM)
}

final class RoutineEditVC: UIViewController {
  // MARK: - Dependencies
  private let presenter: RoutineEditPresenter
  
  // MARK: - Properties
  var emojiSourceRect: CGRect? { contentView.emojiSourceRect }
  
  // MARK: - Private Properties
  private lazy var contentView = RoutineEditView()
  
  // MARK: - Init
  init(presenter: RoutineEditPresenter) {
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
    setupActions()
    presenter.viewDidLoad()
  }
}

// MARK: - RoutineEditViewInterface
extension RoutineEditVC: RoutineEditViewInterface {
  func update(title: String) {
    self.title = title
  }
  
  func updateDelete(visibility isVisible: Bool) {
    contentView.updateDelete(visibility: isVisible)
  }
  
  func update(with snapshot: Snapshot<RoutineEdit.Section, RoutineEdit.Row>) {
    contentView.update(with: snapshot)
  }
  
  func showAlert(with viewModel: Alert.VM) {
    DispatchQueue.main.async {
      Alert.show(on: self, with: viewModel)      
    }
  }
}

// MARK: - Actions
extension RoutineEditVC {
  @objc private func cancel() {
    presenter.cancelEdit()
  }
  
  @objc private func save() {
    presenter.save()
  }
}

// MARK: - Private
extension RoutineEditVC {
  private func setupUI() {
    setupNavBar()
  }
  
  private func setupNavBar() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: RoutineAppStrings.NavBar.cancel,
      style: .plain,
      target: self,
      action: #selector(cancel)
    )
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: RoutineAppStrings.NavBar.save,
      style: .done,
      target: self,
      action: #selector(save)
    )
  }
  
  private func setupActions() {
    contentView.onSave = { [weak self] in
      self?.presenter.save()
    }
    contentView.onDelete = { [weak self] in
      self?.presenter.delete()
    }
    contentView.onNameChange = { [weak self] in
      self?.presenter.nameChanged($0)
    }
    contentView.onDescriptionChange = { [weak self] in
      self?.presenter.descriptionChanged($0)
    }
    contentView.onRemindMeChangeRequest = { [weak self] in
      self?.presenter.remindMeChangeRequest($0)
    }
    contentView.onAddReminder = { [weak self] in
      self?.presenter.addReminder()
    }
    contentView.onDeleteReminder = { [weak self] in
      self?.presenter.deleteReminder(at: $0)
    }
  }
}
