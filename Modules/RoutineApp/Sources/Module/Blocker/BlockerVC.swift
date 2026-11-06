import SnapKit
import UIKit

final class BlockerVC: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    let icon = UIImageView(image: UIImage(systemName: "lock.fill"))
    icon.contentMode = .scaleAspectFit
    icon.tintColor = .secondaryLabel
    icon.snp.makeConstraints { $0.size.equalTo(40) }
    let title = UILabel()
    title.text = RoutineAppStrings.Localizable.Lock.title
    title.font = .preferredFont(forTextStyle: .headline)
    let stack = UIStackView(arrangedSubviews: [icon, title])
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 20
    view.addSubview(stack)
    stack.snp.makeConstraints { $0.center.equalToSuperview() }
  }
}
