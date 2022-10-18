import SnapKit
import UIKit

final class TextViewCell: UICollectionViewCell, ModelConfigurable {
  // MARK: - Public Properties
  var onTextChange: ((String) -> Void)?
  var onBeginEditing: (() -> Void)?
  var onEndEditing: (() -> Void)?
  
  // MARK: - UI Properties
  private lazy var textView = createTextView()
  
  // MARK: - ModelConfigurable
  func update(with model: TextViewCellVM) {
    textView.placeholder = model.placeholder
  }
}

// MARK: - UITextViewDelegate
extension TextViewCell: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    onTextChange?(textView.text)
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    onBeginEditing?()
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    onEndEditing?()
  }
}
  
// MARK: - Private
extension TextViewCell {
  private func createTextView() -> UITextView {
    with(UITextView()) {
      $0.font = Font.system(.body, weight: .regular)
      $0.textColor = Color.Text.default
      $0.backgroundColor = Color.Background.secondary
      $0.textAlignment = .left
      $0.delegate = self
      contentView.addSubview($0)
      
      $0.snp.makeConstraints {
        $0.leading.trailing.equalToSuperview().inset(Inset.Padding.default)
        $0.top.bottom.equalToSuperview()
        $0.height.equalTo(100)
      }
    }
  }
}
