import PinLayout
import UIKit

final class ValueCell: UITableViewCell, ModelConfigurable {  
  // MARK: - UI Properties
  private lazy var titleLabel = createTitleLabel()
  private lazy var valueLabel = createValueLabel()
  
  // MARK: - ModelConfigurable
  func update(with model: ValueCellVM) {
    titleLabel.text = model.title
    valueLabel.text = model.value
    
    switch model.valueStyle {
    case .default:
      valueLabel.font = Font.system(.footnote, weight: .regular)
      valueLabel.textColor = Color.Text.value
    case .bold:
      valueLabel.font = Font.system(.footnote, weight: .semibold)
      valueLabel.textColor = Color.Text.default
    }
    
    switch model.accessory {
    case .none:
      accessoryType = .none
    case .disclosure:
      accessoryType = .disclosureIndicator
    }
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
      .right(accessoryType == .none ? Inset.Side.default : Inset.Side.small)
      .maxWidth(50%)
      .sizeToFit()
    
    // title
    titleLabel.pin
      .top()
      .bottom()
      .left(Inset.Side.default)
      .before(of: valueLabel)
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
