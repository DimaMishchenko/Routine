import PinLayout
import UIKit

final class ValueCell: UICollectionViewListCell, ModelConfigurable {
  // MARK: - Constants
  private enum Constants {
    static let colorSize: CGFloat = 20
  }
  
  // MARK: - UI Properties
  var valueSourceRect: CGRect? { valueLabel.frameRelativeToVC }
  
  private lazy var iconImageView = createIconImageView()
  private lazy var titleLabel = createTitleLabel()
  private lazy var valueLabel = createValueLabel()
  private lazy var colorView = createColorView()
  
  // MARK: - ModelConfigurable
  func update(with model: ValueCellVM) {
    iconImageView.image = model.icon
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
    // icon
    iconImageView.pin
      .vCenter()
      .left(Inset.Padding.default)
      .size(Size.Icon.default)
    
    // value
    valueLabel.pin
      .vCenter()
      .right(accessories.isEmpty ? Inset.Padding.default : Inset.Padding.small)
      .maxWidth(50%)
      .sizeToFit()
    
    // title
    let titlePin = titleLabel.pin
      .top()
      .bottom()
      .before(of: valueLabel)
    
    if iconImageView.image == nil {
      titlePin.left(Inset.Padding.default)
    } else {
      titlePin.after(of: iconImageView).marginLeft(Inset.Padding.small)
    }
    
    // colorView
    colorView.pin
      .vCenter()
      .right(accessories.isEmpty ? Inset.Padding.default : Inset.Padding.small)
      .size(Constants.colorSize)
  }
  
  private func createIconImageView() -> UIImageView {
    with(UIImageView()) {
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
  
  private func createColorView() -> UIView {
    with(UIView()) {
      $0.layer.cornerRadius = Size.CornerRadius.button
      contentView.addSubview($0)
    }
  }
}
