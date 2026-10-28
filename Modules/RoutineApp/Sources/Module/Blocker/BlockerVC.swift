import SnapKit
import UIKit

final class BlockerVC: UIViewController {
  private let onUnlock: () -> Void
  private lazy var unlockButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle(RoutineAppStrings.Localizable.Lock.unlock, for: .normal)
    button.addTarget(self, action: #selector(unlock), for: .touchUpInside)
    return button
  }()
  private var authenticating = false

  init(onUnlock: @escaping () -> Void) {
    self.onUnlock = onUnlock
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

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
    let stack = UIStackView(arrangedSubviews: [icon, title, unlockButton])
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 20
    view.addSubview(stack)
    stack.snp.makeConstraints { $0.center.equalToSuperview() }
    update(authenticating: authenticating)
  }

  func update(authenticating: Bool) {
    self.authenticating = authenticating
    guard isViewLoaded else { return }
    unlockButton.isEnabled = !authenticating
  }

  @objc private func unlock() {
    onUnlock()
  }
}
