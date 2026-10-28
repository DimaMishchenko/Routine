import UIKit

final class BlockerAssembly {
  func controller(onUnlock: @escaping () -> Void) -> UIViewController {
    BlockerVC(onUnlock: onUnlock)
  }
}
