import EmojiPicker
import UIKit

final class EmojiPickerAssembly {
  // MARK: - Public
  func controller(with sourceView: UIView, onSelection: @escaping (String) -> Void) -> UIViewController {
    let emojiVC = EmojiPickerViewController()
    let delegate = EmojiPickerDelegateProxy(onSelection: onSelection)
    emojiVC.delegate = delegate
    emojiVC.strongDelegateHolder = delegate
    emojiVC.sourceView = sourceView
    return emojiVC
  }
}

extension EmojiPickerViewController {
  private static var strongDelegateHolderKey: UInt8 = 0
  
  fileprivate var strongDelegateHolder: EmojiPickerDelegate? {
    get { objc_getAssociatedObject(self, &Self.strongDelegateHolderKey) as? EmojiPickerDelegate }
    set { objc_setAssociatedObject(self, &Self.strongDelegateHolderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }
}

private final class EmojiPickerDelegateProxy: EmojiPickerDelegate {
  let onSelection: (String) -> Void
  
  init(onSelection: @escaping (String) -> Void) {
    self.onSelection = onSelection
  }
  
  func didGetEmoji(emoji: String) {
    onSelection(emoji)
  }
}
