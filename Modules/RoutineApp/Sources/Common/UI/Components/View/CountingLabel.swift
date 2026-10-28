import SnapKit
import UIKit

final class CountingLabel: UIView {
  var font: UIFont {
    get { label.font }
    set { label.font = newValue }
  }
  
  var color: UIColor {
    get { label.textColor }
    set { label.textColor = newValue }
  }
  
  var prefix: String = .empty
  var suffix: String = .empty
  
  var steps: Int = 20
  var animationDuration: TimeInterval = 0.3
  
  private lazy var label = createLabel()
  
  private var currentValue: Double = .zero
  
  func update(to value: Double, round: Bool, animated: Bool) {
    if animated {
      let current = currentValue
      let steps = self.steps
      let duration = animationDuration
      let rate = duration / Double(steps)
      let diff = value - current
      for step in 0...steps {
        DispatchQueue.main.asyncAfter(deadline: .now() + rate * Double(step)) {
          let value = current + diff * (Double(step) / Double(steps))
          self.label.text = self.prefix + (round ? "\(Int(value))" : "\(value)") + self.suffix
        }
      }
    } else {
      label.text = prefix + (round ? "\(Int(value))" : "\(value)") + suffix
    }
    
    currentValue = value
  }
  
  private func createLabel() -> UILabel {
    with(UILabel()) {
      addSubview($0)
      $0.textAlignment = .center
      $0.adjustsFontSizeToFitWidth = true
      $0.minimumScaleFactor = 0.25
      $0.adjustsFontForContentSizeCategory = true
      $0.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
  }
}
