import UIKit

extension SheetPicker {
  static func goal(
    selectedItem: Progress.Goal,
    from origin: UIView,
    completion: @escaping (Progress.Goal) -> Void
  ) {
    string(
      title: .empty,
      items: [Int](1...Progress.Goal.max.rawValue).map { "\($0)" },
      selectedIndex: selectedItem.rawValue - 1,
      from: origin
    ) { index in
      completion(.init(rawValue: index + 1))
    }
  }
}
