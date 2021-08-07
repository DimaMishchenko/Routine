import UIKit

final class DataSource<Section: Hashable, Row: Hashable>: UICollectionViewDiffableDataSource<Section, Row> {
  // MARK: - Public
  func apply(
    _ snapshot: Snapshot<Section, Row>,
    animatingDifferences: Bool = false,
    completion: (() -> Void)? = nil
  ) {
    var diffableSnapshot = NSDiffableDataSourceSnapshot<Section, Row>()
    
    diffableSnapshot.appendSections(snapshot.items.map { $0.section })
    snapshot.items.forEach {
      diffableSnapshot.appendItems($0.rows, toSection: $0.section)
    }
    
    super.apply(diffableSnapshot, animatingDifferences: animatingDifferences, completion: completion)
  }
}
