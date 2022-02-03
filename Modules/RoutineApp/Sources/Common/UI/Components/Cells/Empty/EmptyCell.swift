import PinLayout
import SnapKit
import UIKit

final class EmptyCell: UICollectionViewCell, ModelConfigurable {
  // MARK: - UI Properties
  private lazy var titleLabel = createTitleLabel()
  
  // MARK: - ModelConfigurable
  func update(with model: EmptyCellVM) {
    titleLabel.text = model.text
    updateBackgroundConfiguration()
  }
  
  // MARK: - Private
  private func updateBackgroundConfiguration() {
    backgroundConfiguration = with(.clear()) {
      $0?.cornerRadius = Size.CornerRadius.container
      $0?.backgroundColor = Color.Background.secondary
    }
  }
  
  private func createTitleLabel() -> UILabel {
    with(UILabel()) {
      $0.font = Font.system(.body, weight: .regular)
      $0.numberOfLines = .zero
      $0.textColor = Color.Text.default
      $0.textAlignment = .left
      contentView.addSubview($0)
      
      $0.snp.makeConstraints {
        $0.edges.equalToSuperview().inset(Inset.Padding.default)
      }
    }
  }
}
