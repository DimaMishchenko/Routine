import PinLayout
import UIKit

final class PlainButtonCell: UICollectionViewCell, ModelConfigurable {
  // MARK: - Public Properties
  var action: (() -> Void)?
  
  // MARK: - UI Properties
  private lazy var button = createButton()
  
  // MARK: - ModelConfigurable
  func update(with model: PlainButtonCellVM) {
    button.setTitle(model.title, for: .normal)
  }
  
  // MARK: - Override
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutViews()
  }
  
  // MARK: - Private
  private func layoutViews() {
    // title
    button.pin
      .top()
      .bottom()
      .left(Inset.Padding.default)
      .right(Inset.Padding.default)
  }
  
  private func createButton() -> UIButton {
    with(UIButton(type: .system)) {
      $0.setTitleColor(Color.Button.default, for: .normal)
      $0.titleLabel?.font = Font.system(.body, weight: .regular)
      $0.contentHorizontalAlignment = .left
      $0.on { [weak self] in self?.action?() }
      addSubview($0)
    }
  }
}
