import PinLayout
import UIKit

final class SwitchCell: UICollectionViewCell, ModelConfigurable {
  // MARK: - Public Properties
  var onChangeRequest: ((_ currentState: Bool) -> Void)?
  
  // MARK: - UI Properties
  private lazy var iconImageView = createIconImageView()
  private lazy var titleLabel = createTitleLabel()
  private lazy var switchView = createSwitch()
  
  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundConfiguration = .listGroupedCell()
  }
  
  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - ModelConfigurable
  func update(with model: SwitchCellVM) {
    iconImageView.image = model.icon
    titleLabel.text = model.title
    switchView.setOn(model.state, animated: true)
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
    switchView.pin
      .vCenter()
      .right(Inset.Padding.default)
      .sizeToFit()
    
    // title
    let titlePin = titleLabel.pin
      .top()
      .bottom()
      .before(of: switchView)
    
    if iconImageView.image == nil {
      titlePin.left(Inset.Padding.default)
    } else {
      titlePin.after(of: iconImageView).marginLeft(Inset.Padding.default)
    }
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
  
  private func createSwitch() -> UISwitch {
    with(UISwitch()) {
      $0.on(.valueChanged) { [weak self] in
        guard let self = self else { return }
        self.switchView.setOn(!self.switchView.isOn, animated: false)
        self.onChangeRequest?(self.switchView.isOn)
      }
      contentView.addSubview($0)
    }
  }
}
