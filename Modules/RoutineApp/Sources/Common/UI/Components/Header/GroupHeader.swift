import SnapKit
import UIKit

final class GroupHeader: UICollectionViewListCell, ModelConfigurable {
  // MARK: - UI Properties
  private lazy var titleLabel = createTitleLabel()
  
  // MARK: - Public
  func update(with model: GroupHeaderVM) {
    titleLabel.text = model.title
    
    switch model.accessory {
    case .none:
      accessories = []
    case .outlineDisclosure:
      accessories = [.outlineDisclosure(options: .init(style: .header, tintColor: Color.Text.header))]
    }
  }

  // MARK: - Private
  private func createTitleLabel() -> UILabel {
    with(UILabel()) {
      $0.font = Font.system(.subhead, weight: .semibold)
      $0.textColor = Color.Text.header
      $0.textAlignment = .left
      addSubview($0)
      
      $0.snp.makeConstraints {
        $0.edges.equalToSuperview().inset(Inset.Side.small)
      }
    }
  }
}
