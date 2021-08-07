import UIKit

final class OutlineDataSource<
  Section: Hashable,
  Header: Hashable,
  Row: Hashable
>: UICollectionViewDiffableDataSource<Section, OutlineRow<Header, Row>> {
  // MARK: - Public
  func apply(
    _ snapshot: Snapshot<Section, OutlineItem<Header, Row>>,
    animatingDifferences: Bool = false,
    completion: (() -> Void)? = nil
  ) {
    snapshot.items.forEach {
      var diffableSectionSnapshot = NSDiffableDataSourceSectionSnapshot<OutlineRow<Header, Row>>()
      
      $0.rows.forEach {
        let header: OutlineRow<Header, Row> = .header($0.header)
        diffableSectionSnapshot.append([header])
        diffableSectionSnapshot.append($0.rows.map { .row($0) }, to: header)
        if $0.open { diffableSectionSnapshot.expand([header]) }
      }
      
      super.apply(
        diffableSectionSnapshot,
        to: $0.section,
        animatingDifferences: animatingDifferences,
        completion: completion
      )
    }
  }
}

// MARK: - OutlineItem
struct OutlineItem<Header: Hashable, Row: Hashable>: Hashable {
  let header: Header
  let open: Bool
  let rows: [Row]
  
  init(
    header: Header,
    open: Bool = false,
    rows: [Row]
  ) {
    self.header = header
    self.open = open
    self.rows = rows
  }
}

// MARK: - OutlineRow
enum OutlineRow<Header: Hashable, Row: Hashable>: Hashable {
  case header(Header)
  case row(Row)
}
