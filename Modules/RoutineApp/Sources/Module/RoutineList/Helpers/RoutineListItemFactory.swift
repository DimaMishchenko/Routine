import Foundation

protocol RoutineListItemFactory {
  typealias Item = Snapshot<RoutineList.Section, OutlineItem<RoutineList.Header, RoutineList.Row>>.Item
  
  func daily(rows: [RoutineList.Row], containsAnyItems: Bool) -> Item
  func weekly(rows: [RoutineList.Row]) -> Item
  func monthly(rows: [RoutineList.Row]) -> Item
}

final class RoutineListItemFactoryImpl: RoutineListItemFactory {
  func daily(rows: [RoutineList.Row], containsAnyItems: Bool) -> Item {
    Item(
      section: .daily,
      rows: [
        .init(
          header: .init(
            model: .init(title: RoutineAppStrings.Localizable.Frequency.daily, accessory: .outlineDisclosure)
          ),
          open: !containsAnyItems || !rows.isEmpty,
          rows: rows.isEmpty ? [emptyRow()] : rows
        )
      ]
    )
  }
  
  func weekly(rows: [RoutineList.Row]) -> Item {
    Item(
      section: .weekly,
      rows: [
        .init(
          header: .init(
            model: .init(title: RoutineAppStrings.Localizable.Frequency.weekly, accessory: .outlineDisclosure)
          ),
          open: !rows.isEmpty,
          rows: rows.isEmpty ? [emptyRow()] : rows
        )
      ]
    )
  }
  
  func monthly(rows: [RoutineList.Row]) -> Item {
    Item(
      section: .monthly,
      rows: [
        .init(
          header: .init(
            model: .init(title: RoutineAppStrings.Localizable.Frequency.monthly, accessory: .outlineDisclosure)
          ),
          open: !rows.isEmpty,
          rows: rows.isEmpty ? [emptyRow()] : rows
        )
      ]
    )
  }
  private func emptyRow() -> RoutineList.Row {
    .init(.empty(.init(text: RoutineAppStrings.Localizable.RoutineList.Row.Empty.text)))
  }
}
