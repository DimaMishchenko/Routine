import UIKit

final class GroupBackgroundView: UICollectionReusableView {
  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Private
  private func setupUI() {
    backgroundColor = Color.Background.secondary
    layer.cornerRadius = Size.CornerRadius.container
  }
}
