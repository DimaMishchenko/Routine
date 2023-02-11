import SnapKit
import UIKit

final class BlockerVC: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    with(UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))) {
      view.addSubview($0)
      $0.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
  }
}
