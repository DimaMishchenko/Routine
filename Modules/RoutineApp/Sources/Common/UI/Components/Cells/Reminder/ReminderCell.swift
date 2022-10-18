import PinLayout
import UIKit

final class ReminderCell: UICollectionViewCell, ModelConfigurable {
  // MARK: - Public Properties
  var onDelete: (() -> Void)?
  var onDateUpdate: ((Date) -> Void)?
  
  // MARK: - UI Properties
  private lazy var deleteButton = createDeleteButton()
  private lazy var titleLabel = createTitleLabel()
  private lazy var datePicker = createDatePicker()
  
  // MARK: - ModelConfigurable
  func update(with model: ReminderCellVM) {
    titleLabel.text = model.title
    datePicker.setDate(model.date, animated: true)
  }
  
  // MARK: - Override
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutViews()
  }
  
  // MARK: - Private
  private func layoutViews() {
    // value
    datePicker.pin
      .vCenter()
      .right(Inset.Padding.default)
      .maxWidth(50%)
      .sizeToFit()
    
    // button
    deleteButton.pin
      .vCenter()
      .size(Size.Button.small)
      .left(Inset.Padding.default)
    
    // title
    titleLabel.pin
      .top()
      .bottom()
      .after(of: deleteButton)
      .marginLeft(Inset.Padding.smedium)
      .before(of: datePicker)
  }
  
  private func createDeleteButton() -> UIButton {
    with(UIButton()) {
      $0.backgroundColor = Color.Button.delete
      $0.layer.cornerRadius = Size.CornerRadius.button
      $0.setImage(RoutineAppAsset.Icon.trash.image, for: .normal)
      $0.on { [weak self] in self?.onDelete?() }
      contentView.addSubview($0)
    }
  }
  
  private func createTitleLabel() -> UILabel {
    with(UILabel()) {
      $0.font = Font.system(.body, weight: .regular)
      $0.textColor = Color.Text.default
      $0.textAlignment = .left
      contentView.addSubview($0)
    }
  }
  
  private func createDatePicker() -> UIDatePicker {
    with(UIDatePicker()) {
      $0.preferredDatePickerStyle = .compact
      $0.datePickerMode = .time
      $0.on(.valueChanged) { [weak self] in
        guard let self = self else { return }
        self.onDateUpdate?(self.datePicker.date)
      }
      contentView.addSubview($0)
    }
  }
}
