import Foundation
import UIKit.UIImage

enum Premium {
  struct Item: Identifiable {
    let id = UUID()
    let icon: UIImage
    let title: String
    let description: String
  }
  
  struct Offer: Identifiable {
    let id: String
    let title: String
    let trialDescription: String?
  }
}
