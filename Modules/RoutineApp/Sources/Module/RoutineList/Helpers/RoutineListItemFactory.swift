import Foundation

protocol RoutineListItemFactory {
  typealias Item = Snapshot<RoutineList.Section, OutlineItem<RoutineList.Header, RoutineList.Row>>.Item
  
  func premium(showBanner: Bool, onSelect: @escaping () -> Void) -> Item
  func daily(rows: [RoutineList.Row], containsAnyItems: Bool) -> Item
  func weekly(rows: [RoutineList.Row]) -> Item
  func monthly(rows: [RoutineList.Row]) -> Item
}

final class RoutineListItemFactoryImpl: RoutineListItemFactory {
  func premium(showBanner: Bool, onSelect: @escaping () -> Void) -> Item {
    Item(
      section: .premium,
      rows: !showBanner ? [] : [
        .init(
          rows: [
            .init(.premium(.init(accesory: .close))) { onSelect() }
          ]
        )
      ]
    )
  }
  
  func daily(rows: [RoutineList.Row], containsAnyItems: Bool) -> Item {
    Item(
      section: .daily,
      rows: [
        .init(
          header: .init(model: .init(title: RoutineAppStrings.Frequency.daily, accessory: .outlineDisclosure)),
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
            model: .init(title: RoutineAppStrings.Frequency.weekly, accessory: .outlineDisclosure)
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
            model: .init(title: RoutineAppStrings.Frequency.monthly, accessory: .outlineDisclosure)
          ),
          open: !rows.isEmpty,
          rows: rows.isEmpty ? [emptyRow()] : rows
        )
      ]
    )
  }
  
  // MARK: - Private
  private func emptyRow() -> RoutineList.Row {
    .init(.empty(.init(text: RoutineAppStrings.RoutineList.Row.Empty.text)))
  }
}
