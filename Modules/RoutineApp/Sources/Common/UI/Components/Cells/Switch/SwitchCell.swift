import PinLayout
import UIKit

final class SwitchCell: UICollectionViewCell, ModelConfigurable {
  // MARK: - Public Properties
  var onChange: ((Bool) -> Void)?
  
  // MARK: - UI Properties
  private lazy var titleLabel = createTitleLabel()
  private lazy var switchView = createSwitch()
  
  // MARK: - ModelConfigurable
  func update(with model: SwitchCellVM) {
    titleLabel.text = model.title
    switchView.isOn = model.state
  }
  
  // MARK: - Override
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutViews()
  }
  
  // MARK: - Actions
  @objc private func switchChanged() {
    onChange?(switchView.isOn)
  }
  
  // MARK: - Private
  private func layoutViews() {
    // value
    switchView.pin
      .vCenter()
      .right(Inset.Padding.default)
      .sizeToFit()
    
    // title
    titleLabel.pin
      .top()
      .bottom()
      .left(Inset.Padding.default)
      .before(of: switchView)
  }
  
  private func createTitleLabel() -> UILabel {
    with(UILabel()) {
      $0.font = Font.system(.body, weight: .regular)
      $0.textColor = Color.Text.default
      $0.textAlignment = .left
      contentView.addSubview($0)
    }
  }
  
  private func createSwitch() -> UISwitch {
    with(UISwitch()) {
      $0.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
      contentView.addSubview($0)
    }
  }
}
