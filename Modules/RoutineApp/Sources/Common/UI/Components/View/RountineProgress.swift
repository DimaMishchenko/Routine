import SnapKit
import UIKit

final class RountineProgress: UIView {
  // MARK: - UI Properties
  private lazy var progress = createProgres()
  private lazy var label = createLabel()
  
  // MARK: - Public
  func update(progress value: Double, animated: Bool, completion: @escaping () -> Void = {}) {
    progress.update(progress: value, animated: animated) { completion() }
    label.update(to: value * 100, round: true, animated: animated)
  }
  
  // MARK: - Private
  private func createProgres() -> CircularProgressView {
    with(CircularProgressView()) {
      addSubview($0)
      $0.progressBackgroundColor = Color.Background.lightBlue
      $0.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
  }
  
  private func createLabel() -> CountingLabel {
    with(CountingLabel()) {
      addSubview($0)
      $0.color = Color.Text.default
      $0.font = Font.system(.footnote, weight: .semibold)
      $0.suffix = "%"
      $0.snp.makeConstraints { $0.center.equalToSuperview() }
    }
  }
}
