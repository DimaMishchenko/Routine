import Foundation
import UIKit.UIImage

enum Tutorial {
  struct WelcomeVM {
    let icon: UIImage
    let title: NSAttributedString
    let description: String
    let actionTitle: String
  }
  
  struct FeaturesVM {
    let title: String
    let message: String
    let actionTitle: String
    let features: [FeatureVM]
  }
  
  struct FeatureVM: Hashable, Identifiable {
    let id = UUID()
    let icon: UIImage
    let title: String
    let description: String
  }
}
