import UIKit

extension UICollectionViewDiffableDataSource {
  func section(at index: Int) -> SectionIdentifierType {
    snapshot().sectionIdentifiers[index]
  }
  
  func row(at indexPath: IndexPath) -> ItemIdentifierType {
    snapshot().itemIdentifiers(inSection: section(at: indexPath.section))[indexPath.row]
  }
}
