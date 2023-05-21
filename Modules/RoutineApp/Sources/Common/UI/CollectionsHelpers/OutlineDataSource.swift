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
        guard let header = $0.header else {
          append($0.rows.map { .row($0) }, to: &diffableSectionSnapshot, outlineTo: nil)
          return
        }
        
        let headerRow: OutlineRow<Header, Row> = .header(header)
        diffableSectionSnapshot.append([headerRow])
        append($0.rows.map { .row($0) }, to: &diffableSectionSnapshot, outlineTo: headerRow)
        if $0.open { diffableSectionSnapshot.expand([headerRow]) }
      }
      
      super.apply(
        diffableSectionSnapshot,
        to: $0.section,
        animatingDifferences: animatingDifferences,
        completion: completion
      )
    }
  }
  
  // MARK: - Private
  private func append(
    _ rows: [OutlineRow<Header, Row>],
    to snapshot: inout NSDiffableDataSourceSectionSnapshot<OutlineRow<Header, Row>>,
    outlineTo outlineRow: OutlineRow<Header, Row>?
  ) {
    if let outlineRow {
      snapshot.append(rows, to: outlineRow)
    } else {
      snapshot.append(rows)
    }
  }
}

// MARK: - OutlineItem
struct OutlineItem<Header: Hashable, Row: Hashable>: Hashable {
  let header: Header?
  let open: Bool
  let rows: [Row]
  
  init(
    header: Header? = nil,
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
