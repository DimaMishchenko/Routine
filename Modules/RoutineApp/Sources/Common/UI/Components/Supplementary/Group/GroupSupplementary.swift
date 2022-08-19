import SnapKit
import UIKit

final class GroupSupplementary: UICollectionViewListCell, ModelConfigurable {
  // MARK: - Public
  func update(with model: GroupSupplementaryVM) {
    contentConfiguration = with(UIListContentConfiguration.groupedHeader()) {
      $0.text = model.title
      $0.textProperties.font = Font.system(.caption1, weight: .semibold)
    }
    backgroundConfiguration = .clear()
    
    switch model.accessory {
    case .none:
      accessories = []
    case .outlineDisclosure:
      accessories = [.outlineDisclosure(options: .init(style: .header, tintColor: Color.Text.header))]
    }
  }
}
