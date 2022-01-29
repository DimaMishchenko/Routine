import UIKit

final class ShareAssembly {
  // MARK: - Public
  func controller(items: [Any]) -> UIViewController {
    UIActivityViewController(activityItems: items, applicationActivities: nil)
  }
}
