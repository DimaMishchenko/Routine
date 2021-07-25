import UIKit

final class TableDataSource<Section: Hashable, Row: Hashable>: UITableViewDiffableDataSource<Section, Row> {
  // MARK: - Properties
  var titleForHeader: ((Section) -> String)?
  
  // MARK: - Public
  func section(at index: Int) -> Section {
    snapshot().sectionIdentifiers[index]
  }
  
  func row(at indexPath: IndexPath) -> Row {
    snapshot().itemIdentifiers(inSection: section(at: indexPath.section))[indexPath.row]
  }
  
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
  
  // MARK: - Override
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    titleForHeader?(self.section(at: section))
  }
}
