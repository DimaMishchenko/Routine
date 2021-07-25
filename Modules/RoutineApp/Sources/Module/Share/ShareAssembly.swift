import UIKit

final class ShareAsembly {
  // MARK: - Public
  func controller(items: [Any]) -> UIViewController {
    UIActivityViewController(activityItems: items, applicationActivities: nil)
  }
}
