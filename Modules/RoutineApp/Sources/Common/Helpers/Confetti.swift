import SPConfetti
import UIKit

enum Confetti {
  static func run(with emoji: String) {
    let string = NSAttributedString(string: emoji, attributes: [.font: UIFont.systemFont(ofSize: CGFloat(30))])
    let image = UIGraphicsImageRenderer(size: string.size()).image { _ in string.draw(at: .zero) }
    
    SPConfetti.startAnimating(
      .fullWidthToDown,
      particles: [.arc, .heart, .custom(image)],
      duration: 1,
      in: UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    )
  }
}
