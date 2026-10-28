import PinLayout
import UIKit

final class TextFieldCell: UICollectionViewCell, ModelConfigurable {
  var onTextChange: ((String) -> Void)?
  var onBeginEditing: (() -> Void)?
  
  private lazy var textField = createTextField()
  
  func update(with model: TextFieldCellVM) {
    textField.text = model.text
    textField.attributedPlaceholder = NSAttributedString(
      string: model.placeholder,
      attributes: [.foregroundColor: Color.Text.placeholder]
    )
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutViews()
  }
}

extension TextFieldCell {
  @objc private func textFieldDidChange() {
    onTextChange?(textField.text ?? .empty)
  }
}

extension TextFieldCell: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    onBeginEditing?()
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return true
  }
}
  
extension TextFieldCell {
  private func layoutViews() {
    textField.pin.all(
      UIEdgeInsets(
        top: .zero,
        left: Inset.Padding.default,
        bottom: .zero,
        right: Inset.Padding.default
      )
    )
  }
  
  private func createTextField() -> UITextField {
    with(UITextField()) {
      $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
      $0.font = Font.system(.body, weight: .regular)
      $0.adjustsFontForContentSizeCategory = true
      $0.textColor = Color.Text.default
      $0.textAlignment = .natural
      $0.returnKeyType = .done
      $0.delegate = self
      contentView.addSubview($0)
    }
  }
}
