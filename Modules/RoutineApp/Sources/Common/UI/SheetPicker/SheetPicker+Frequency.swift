import UIKit

extension SheetPicker {
  static func frequency(
    selectedItem: Frequency,
    from origin: UIView,
    completion: @escaping (Frequency) -> Void
  ) {
    string(
      title: .empty,
      items: Frequency.allCases.map { $0.localized },
      selectedIndex: Frequency.allCases.firstIndex(of: selectedItem) ?? .zero,
      from: origin
    ) { index in
      completion(Frequency.allCases[safe: index] ?? selectedItem)
    }
  }
}
