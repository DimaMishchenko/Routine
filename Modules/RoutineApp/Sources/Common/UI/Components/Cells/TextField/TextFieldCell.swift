import PinLayout
import UIKit

final class TextFieldCell: UICollectionViewCell, ModelConfigurable {
  // MARK: - Public Properties
  var onTextChange: ((String) -> Void)?
  
  // MARK: - UI Properties
  private lazy var textField = createTextField()
  
  // MARK: - ModelConfigurable
  func update(with model: TextFieldCellVM) {
    textField.text = model.text
    textField.attributedPlaceholder = NSAttributedString(
      string: model.placeholder,
      attributes: [.foregroundColor: Color.Text.placeholder]
    )
  }
  
  // MARK: - Override
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutViews()
  }
}

// MARK: - Actions
extension TextFieldCell {
  @objc private func textFieldDidChange() {
    onTextChange?(textField.text ?? .empty)
  }
}

// MARK: - UITextFieldDelegate
extension TextFieldCell: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return true
  }
}
  
// MARK: - Private
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
      $0.textColor = Color.Text.default
      $0.textAlignment = .left
      $0.returnKeyType = .done
      $0.delegate = self
      contentView.addSubview($0)
    }
  }
}
