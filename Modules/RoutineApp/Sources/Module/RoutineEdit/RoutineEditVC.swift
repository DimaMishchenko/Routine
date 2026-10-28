import UIKit

protocol RoutineEditViewInterface: AnyObject {
  func update(title: String)
  func updateDelete(visibility isVisible: Bool)
  func update(with snapshot: Snapshot<RoutineEdit.Section, RoutineEdit.Row>)
  func showAlert(with viewModel: Alert.VM)
}

final class RoutineEditVC: UIViewController {
  private let presenter: RoutineEditPresenter
  
  var emojiSourceView: UIView? { contentView.emojiSourceView }
  
  private lazy var contentView = RoutineEditView()
  
  init(presenter: RoutineEditPresenter) {
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
    setupActions()
    presenter.viewDidLoad()
  }
}

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
    Alert.show(on: self, with: viewModel)
  }
}

extension RoutineEditVC {
  @objc private func cancel() {
    presenter.cancelEdit()
  }
  
  @objc private func save() {
    presenter.save()
  }
}

extension RoutineEditVC {
  private func setupUI() {
    setupNavBar()
  }
  
  private func setupNavBar() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: RoutineAppStrings.Localizable.NavBar.cancel,
      style: .plain,
      target: self,
      action: #selector(cancel)
    )
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: RoutineAppStrings.Localizable.NavBar.save,
      style: .prominent,
      target: self,
      action: #selector(save)
    )
  }
  
  private func setupActions() {
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
    contentView.onUpdateReminderDate = { [weak self] in
      self?.presenter.updateReminder(date: $0, at: $1)
    }
    contentView.onGoalChange = { [weak self] in
      self?.presenter.goalChanged($0)
    }
    contentView.onFrequencyChange = { [weak self] in
      self?.presenter.frequencyChanged($0)
    }
  }
}
