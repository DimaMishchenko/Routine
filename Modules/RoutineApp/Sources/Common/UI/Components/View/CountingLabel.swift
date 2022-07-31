import SnapKit
import UIKit

final class CountingLabel: UIView {
  // MARK: - Public Properties
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
  
  // MARK: - UI Properties
  private lazy var label = createLabel()
  
  // MARK: - Private Properties
  private var currentValue: Double = .zero
  
  // MARK: - Public
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
  
  // MARK: - Private
  private func createLabel() -> UILabel {
    with(UILabel()) {
      addSubview($0)
      $0.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
  }
}
