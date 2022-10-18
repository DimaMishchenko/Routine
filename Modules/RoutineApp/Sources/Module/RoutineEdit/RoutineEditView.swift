import PinLayout
import SnapKit
import UIKit

final class RoutineEditView: UIView {
  // MARK: - Public Properties
  var onSave: (() -> Void)?
  var onDelete: (() -> Void)?
  
  var onNameChange: ((String) -> Void)?
  var onDescriptionChange: ((String) -> Void)?
  var onRemindMeChangeRequest: ((Bool) -> Void)?
  var onAddReminder: (() -> Void)?
  var onDeleteReminder: ((Int) -> Void)?
  var onUpdateReminderDate: ((Date, Int) -> Void)?
  var onGoalChange: ((Progress.Goal) -> Void)?
  var onFrequencyChange: ((Frequency) -> Void)?
  
  // MARK: - Private Properties
  private var initialLayout = Once()
  
  // MARK: - UI Properties
  var emojiSourceRect: CGRect? { emojiCell?.valueSourceRect }
  private weak var emojiCell: ValueCell?
  
  private lazy var collectionView = createCollectionView()
  private lazy var dataSource = createDataSource()
  private lazy var saveButton = createSaveButton()
  private lazy var deleteButton = createDeleteButton()
  
  // MARK: - Override
  override func layoutSubviews() {
    super.layoutSubviews()
    initialLayout.once { setupUI() }
    updateLayout()
  }
}

// MARK: - Public
extension RoutineEditView {
  func updateDelete(visibility isVisible: Bool) {
    deleteButton.isHidden = !isVisible
    layoutIfNeeded()
  }
  
  func update(with snapshot: Snapshot<RoutineEdit.Section, RoutineEdit.Row>) {
    dataSource.apply(snapshot, animatingDifferences: true)
  }
}

// MARK: - UICollectionViewDelegate
extension RoutineEditView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    dataSource.row(at: indexPath).action?()
    collectionView.deselectItem(at: indexPath, animated: true)
  }
}

// MARK: - Private
extension RoutineEditView {
  private func setupUI() {
    backgroundColor = Color.Background.default
    setupTapToHideKeyboard()
  }
  
  private func updateLayout() {
    deleteButton.pin
      .bottom(pin.safeArea)
      .left(Inset.Padding.default)
      .right(Inset.Padding.default)
      .height(Size.Button.big)
    
    saveButton.pin
      .left(Inset.Padding.default)
      .right(Inset.Padding.default)
      .height(Size.Button.big)
    
    if deleteButton.isHidden {
      saveButton.pin.bottom(pin.safeArea)
    } else {
      saveButton.pin.above(of: deleteButton).marginBottom(Inset.Padding.small)
    }
  }
  
  private func createDataSource() -> DataSource<RoutineEdit.Section, RoutineEdit.Row> {
    DataSource<RoutineEdit.Section, RoutineEdit.Row>(
      collectionView: collectionView
    ) { [weak self] _, indexPath, row -> UICollectionViewCell? in
      let cell = self?.cell(for: row, at: indexPath)
      cell?.backgroundConfiguration = .clear()
      return cell
    }
  }
  
  // swiftlint:disable:next function_body_length
  private func cell(for row: RoutineEdit.Row, at indexPath: IndexPath) -> UICollectionViewCell? {
    switch row.type {
    case .textfield(let viewModel):
      return collectionView.dequeue(TextFieldCell.self, with: viewModel, for: indexPath) {
        $0.onTextChange = { [weak self] in self?.onNameChange?($0) }
      }
    case .textview(let viewModel):
      return collectionView.dequeue(TextViewCell.self, with: viewModel, for: indexPath) {
        $0.onTextChange = { [weak self] in self?.onDescriptionChange?($0) }
        $0.onBeginEditing = { [weak self] in
          guard let self = self else { return }
          self.collectionView.contentInset = self.collectionContentInset(keyboard: true)
          self.dataSource.indexPath(for: row).flatMap {
            self.collectionView.scrollToItem(at: $0, at: .bottom, animated: true)
          }
        }
        $0.onEndEditing = { [weak self] in
          guard let self = self else { return }
          UIView.animate(withDuration: 0.3) {
            self.collectionView.contentInset = self.collectionContentInset(keyboard: false)
          }
        }
      }
    case .value(let viewModel):
      return collectionView.dequeue(ValueCell.self, with: viewModel, for: indexPath) {
        guard case .emoji = viewModel.value else { return }
        emojiCell = $0
      }
    case .switch(let viewModel):
      return collectionView.dequeue(SwitchCell.self, with: viewModel, for: indexPath) {
        $0.onChangeRequest = { [weak self] in self?.onRemindMeChangeRequest?($0) }
      }
    case .plainButton(let viewModel):
      return collectionView.dequeue(PlainButtonCell.self, with: viewModel, for: indexPath) {
        $0.action = { [weak self] in self?.onAddReminder?() }
      }
    case .reminder(let viewModel):
      return collectionView.dequeue(ReminderCell.self, with: viewModel, for: indexPath) {
        $0.onDelete = { [weak self] in
          guard let indexPath = self?.dataSource.indexPath(for: row) else { return }
          self?.onDeleteReminder?(indexPath.row)
        }
        $0.onDateUpdate = { [weak self] in
          guard let indexPath = self?.dataSource.indexPath(for: row) else { return }
          self?.onUpdateReminderDate?($0, indexPath.row)
        }
      }
    case .goalPicker(let viewModel):
      return collectionView.dequeue(PickerCell<Progress.Goal>.self, with: viewModel, for: indexPath) {
        $0.onValueChanged = { [weak self] in self?.onGoalChange?($0) }
        $0.valueTitleProvider = { $1 ? "\($0.rawValue)" : "\($0.rawValue) \(RoutineAppStrings.Common.times)" }
      }
    case .frequencyPicker(let viewModel):
      return collectionView.dequeue(PickerCell<Frequency>.self, with: viewModel, for: indexPath) {
        $0.onValueChanged = { [weak self] in self?.onFrequencyChange?($0) }
        $0.valueTitleProvider = { value, _ in value.localized }
      }
    }
  }
  
  private func createCollectionView() -> UICollectionView {
    with(UICollectionView(layout: createLayout())) {
      $0.delegate = self
      $0.contentInset = collectionContentInset()
      $0.backgroundColor = Color.Background.default
      $0.delaysContentTouches = false
      
      $0.register(TextFieldCell.self)
      $0.register(TextViewCell.self)
      $0.register(ValueCell.self)
      $0.register(SwitchCell.self)
      $0.register(PlainButtonCell.self)
      $0.register(ReminderCell.self)
      $0.register(PickerCell<Progress.Goal>.self)
      $0.register(PickerCell<Frequency>.self)
      
      addSubview($0)
      $0.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
  }
  
  private func collectionContentInset(keyboard: Bool = false) -> UIEdgeInsets {
    let keyboardInset: CGFloat = keyboard ? 250 : 0
    return .init(
      top: Inset.Padding.default,
      left: .zero,
      bottom: keyboardInset + Size.Button.big + Inset.Padding.default + Size.Button.small, // buttons height
      right: .zero
    )
  }
  
  private func createLayout() -> CompositionalLayout {
    CompositionalLayout(
      itemContentInset: NSDirectionalEdgeInsets(
        top: .zero,
        leading: Inset.Padding.default,
        bottom: .zero,
        trailing: Inset.Padding.default
      ),
      applyGroupBackground: { [weak self] index in
        guard case .addReminder = self?.dataSource.section(at: index) else { return true }
        return false
      }
    )
  }
  
  private func createSaveButton() -> UIButton {
    with(UIButton(type: .system)) {
      insertSubview($0, aboveSubview: collectionView)
      $0.on { [weak self] in self?.onSave?() }
      $0.setTitle(RoutineAppStrings.RoutineEdit.Button.save, for: .normal)
      $0.layer.cornerRadius = Size.CornerRadius.buttonBig
      $0.layer.cornerCurve = .continuous
      $0.backgroundColor = Color.Button.default
      $0.titleLabel?.font = Font.system(.body, weight: .medium)
      $0.setTitleColor(Color.Text.light, for: .normal)
    }
  }
  
  private func createDeleteButton() -> UIButton {
    with(UIButton(type: .system)) {
      insertSubview($0, aboveSubview: collectionView)
      $0.on { [weak self] in self?.onDelete?() }
      $0.setTitle(RoutineAppStrings.RoutineEdit.Button.delete, for: .normal)
      $0.titleLabel?.font = Font.system(.body, weight: .medium)
      $0.tintColor = Color.Button.delete
      $0.imageEdgeInsets = .init(top: .zero, left: .zero, bottom: .zero, right: Inset.Padding.default)
      $0.setImage(RoutineAppAsset.Icon.deletePlain.image, for: .normal)
      $0.setTitleColor(Color.Button.delete, for: .normal)
    }
  }
  
  private func setupTapToHideKeyboard() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
    tap.cancelsTouchesInView = false
    addGestureRecognizer(tap)
  }
}
