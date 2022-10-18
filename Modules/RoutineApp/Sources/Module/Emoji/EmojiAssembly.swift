import EmojiPicker

final class EmojiAssembly {
  // MARK: - Public
  func controller(sourceRect: CGRect, onSelected: @escaping (String) -> Void) -> UIViewController {
    let emojiVC = EmojiPicker.viewController
    emojiVC.sourceRect = sourceRect
    emojiVC.onSelected = onSelected
    emojiVC.dismissAfterSelected = true
    emojiVC.size = .init(width: 250, height: 350)
    emojiVC.delegate = emojiVC
    emojiVC.isDarkMode = emojiVC.traitCollection.userInterfaceStyle == .dark
    return emojiVC
  }
}

extension EmojiPickerViewController: EmojiPickerViewControllerDelegate {
  private enum Key {
    static var onSelected = "onSelectedKey"
  }
  
  typealias OnSelected = (String) -> Void

  var onSelected: OnSelected? {
    get { objc_getAssociatedObject(self, &Key.onSelected) as? OnSelected }
    set { objc_setAssociatedObject(self, &Key.onSelected, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  // MARK: - EmojiPickerViewControllerDelegate
  public func emojiPickerViewController(_ controller: EmojiPickerViewController, didSelect emoji: String) {
    onSelected?(emoji)
  }
}
