import PinLayout
import UIKit

final class ValueCell: UICollectionViewListCell, ModelConfigurable {
  // MARK: - Constants
  private enum Constants {
    static let colorSize: CGFloat = 20
  }
  
  // MARK: - UI Properties
  var valueSourceRect: CGRect? { valueLabel.frameRelativeToVC }
  
  private lazy var titleLabel = createTitleLabel()
  private lazy var valueLabel = createValueLabel()
  private lazy var colorView = createColorView()
  
  // MARK: - ModelConfigurable
  func update(with model: ValueCellVM) {
    titleLabel.text = model.title
    
    switch model.value {
    case let .text(text, style):
      colorView.isHidden = true
      valueLabel.text = text
      
      switch style {
      case .default:
        valueLabel.font = Font.system(.footnote, weight: .regular)
        valueLabel.textColor = Color.Text.value
      case .bold:
        valueLabel.font = Font.system(.footnote, weight: .semibold)
        valueLabel.textColor = Color.Text.default
      }
      
    case .emoji(let emoji):
      colorView.isHidden = true
      valueLabel.text = emoji
      valueLabel.font = Font.system(.body, weight: .regular)
      
    case .color(hex: let hexString):
      colorView.isHidden = false
      colorView.backgroundColor = hexString.flatMap { UIColor(hex: $0) }
      valueLabel.text = nil
      
    default:
      colorView.isHidden = true
      valueLabel.text = nil
    }
    
    switch model.accessory {
    case .none:
      accessories = []
    case .disclosure:
      accessories = [.disclosureIndicator()]
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
      .right(accessories.isEmpty ? Inset.Padding.default : Inset.Padding.small)
      .maxWidth(50%)
      .sizeToFit()
    
    // title
    titleLabel.pin
      .top()
      .bottom()
      .left(Inset.Padding.default)
      .before(of: valueLabel)
    
    // colorView
    colorView.pin
      .vCenter()
      .right(accessories.isEmpty ? Inset.Padding.default : Inset.Padding.small)
      .size(Constants.colorSize)
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
  
  private func createColorView() -> UIView {
    with(UIView()) {
      $0.layer.cornerRadius = Size.CornerRadius.button
      contentView.addSubview($0)
    }
  }
}
