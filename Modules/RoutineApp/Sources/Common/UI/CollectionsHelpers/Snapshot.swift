import Foundation

struct Snapshot<Section: Hashable, Row: Hashable> {
  // MARK: - Properties
  let items: [Item]
  
  // MARK: - Init
  init(items: [Item]) {
    self.items = items
  }
  
  init(@SnapshotBuilder<Section, Row> builder: () -> [Item]) {
    self.items = builder()
  }
}

// MARK: - Item
extension Snapshot {
  struct Item {
    let section: Section
    let rows: [Row]
  }
}
