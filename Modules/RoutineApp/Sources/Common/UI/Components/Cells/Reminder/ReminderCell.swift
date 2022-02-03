import PinLayout
import UIKit

final class ReminderCell: UICollectionViewCell, ModelConfigurable {
  // MARK: - Public Properties
  var onDelete: (() -> Void)?
  
  // MARK: - UI Properties
  private lazy var deleteButton = createDeleteButton()
  private lazy var titleLabel = createTitleLabel()
  private lazy var valueLabel = createValueLabel()
  
  // MARK: - ModelConfigurable
  func update(with model: ReminderCellVM) {
    titleLabel.text = model.title
    valueLabel.text = model.value
  }
  
  // MARK: - Override
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutViews()
  }
  
  // MARK: - Private
  private func layoutViews() {
    // value
    valueLabel.pin
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
      .before(of: valueLabel)
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
  
  private func createValueLabel() -> UILabel {
    with(UILabel()) {
      $0.font = Font.system(.footnote, weight: .regular)
      $0.textColor = Color.Text.value
      $0.textAlignment = .right
      contentView.addSubview($0)
    }
  }
}
