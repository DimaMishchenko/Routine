import UIKit

extension UITextView {
  // MARK: - Constants
  private enum Constants {
    static let placeholderLabelTag = 1111
  }
  
  // MARK: - Public
  public var placeholder: String? {
    get {
      placeholderLabel.text
    }
    set {
      placeholderLabel.text = newValue
      placeholderLabel.sizeToFit()
    }
  }
  
  // MARK: - Override
  override open var bounds: CGRect {
    didSet {
      resizePlaceholder()
    }
  }
  
  // MARK: - Private
  private var placeholderLabel: UILabel {
    viewWithTag(Constants.placeholderLabelTag) as? UILabel ?? createPlaceholder()
  }
  
  @objc private func textViewDidChange(_ notification: NSNotification) {
    guard let textView = notification.object as? UITextView, textView === self else { return }
    placeholderLabel.isHidden = !text.isEmpty
  }
  
  private func createPlaceholder() -> UILabel {
    with(UILabel()) {
      $0.sizeToFit()
      $0.font = font
      $0.textColor = Color.Text.placeholder
      $0.tag = Constants.placeholderLabelTag
      $0.isHidden = !text.isEmpty
      addSubview($0)
      resizePlaceholder()
      
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(textViewDidChange),
        name: UITextView.textDidChangeNotification,
        object: nil
      )
    }
  }
  
  private func resizePlaceholder() {
    placeholderLabel.frame = CGRect(
      x: textContainerInset.left + textContainer.lineFragmentPadding,
      y: textContainerInset.top,
      width: frame.width - (textContainerInset.left * 2),
      height: placeholderLabel.frame.height
    )
  }
}
