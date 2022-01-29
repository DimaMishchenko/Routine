import Foundation

// swiftlint:disable:next convenience_type
@resultBuilder struct SnapshotBuilder<Section: Hashable, Row: Hashable> {
  typealias Item = Snapshot<Section, Row>.Item
  
  static func buildExpression(_ item: Item) -> [Item] { [item] }
  static func buildOptional(_ items: [Item]?) -> [Item] { items ?? [] }
  static func buildEither(first items: [Item]) -> [Item] { items }
  static func buildEither(second items: [Item]) -> [Item] { items }
  static func buildArray(_ items: [[Item]]) -> [Item] { Array(items.joined()) }
  static func buildBlock(_ items: [Item]...) -> [Item] { Array(items.joined()) }
}
