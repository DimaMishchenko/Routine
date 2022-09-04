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
  
  private func cell(for row: RoutineEdit.Row, at indexPath: IndexPath) -> UICollectionViewCell? {
    switch row.type {
    case .textfield(let viewModel):
      return with(collectionView.dequeue(TextFieldCell.self, with: viewModel, for: indexPath)) {
        $0?.onTextChange = { [weak self] in self?.onNameChange?($0) }
      }
    case .textview(let viewModel):
      return with(collectionView.dequeue(TextViewCell.self, with: viewModel, for: indexPath)) {
        $0?.onTextChange = { [weak self] in self?.onDescriptionChange?($0) }
      }
    case .value(let viewModel):
      return with(collectionView.dequeue(ValueCell.self, with: viewModel, for: indexPath)) {
        guard case .emoji = viewModel.value else { return }
        emojiCell = $0
      }
    case .switch(let viewModel):
      return with(collectionView.dequeue(SwitchCell.self, with: viewModel, for: indexPath)) {
        $0?.onChangeRequest = { [weak self] in self?.onRemindMeChangeRequest?($0) }
      }
    case .plainButton(let viewModel):
      return with(collectionView.dequeue(PlainButtonCell.self, with: viewModel, for: indexPath)) {
        $0?.action = { [weak self] in self?.onAddReminder?() }
      }
    case .reminder(let viewModel):
      return with(collectionView.dequeue(ReminderCell.self, with: viewModel, for: indexPath)) {
        $0?.onDelete = { [weak self] in
          guard let indexPath = self?.dataSource.indexPath(for: row) else { return }
          self?.onDeleteReminder?(indexPath.row)
        }
      }
    }
  }
  
  private func createCollectionView() -> UICollectionView {
    with(UICollectionView(layout: createLayout())) {
      $0.delegate = self
      $0.contentInset = .init(
        top: Inset.Padding.default,
        left: .zero,
        bottom: Size.Button.big + Inset.Padding.default + Size.Button.small, // buttons height
        right: .zero
      )
      $0.backgroundColor = Color.Background.default
      $0.delaysContentTouches = false
      
      $0.register(TextFieldCell.self)
      $0.register(TextViewCell.self)
      $0.register(ValueCell.self)
      $0.register(SwitchCell.self)
      $0.register(PlainButtonCell.self)
      $0.register(ReminderCell.self)
      
      addSubview($0)
      $0.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
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
}
