import SnapKit
import UIKit

final class StorageRecoveryVC: UIViewController {
  private let onRetry: () -> Void

  init(onRetry: @escaping () -> Void) {
    self.onRetry = onRetry
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    let title = UILabel()
    title.text = RoutineAppStrings.Localizable.StorageError.title
    title.font = .preferredFont(forTextStyle: .headline)
    title.numberOfLines = .zero
    title.textAlignment = .center
    let message = UILabel()
    message.text = RoutineAppStrings.Localizable.StorageError.message
    message.font = .preferredFont(forTextStyle: .body)
    message.numberOfLines = .zero
    message.textAlignment = .center
    let retry = UIButton(type: .system)
    retry.setTitle(RoutineAppStrings.Localizable.StorageError.retry, for: .normal)
    retry.addTarget(self, action: #selector(retryOpeningStore), for: .touchUpInside)
    let stack = UIStackView(arrangedSubviews: [title, message, retry])
    stack.axis = .vertical
    stack.spacing = 20
    view.addSubview(stack)
    stack.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(24)
    }
  }

  @objc private func retryOpeningStore() {
    onRetry()
  }
}
