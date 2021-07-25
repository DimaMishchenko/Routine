import UIKit

extension Alert {
  struct FiledsVM<Fields: CaseIterable & AlertFields> where Fields.AllCases.Element: Hashable {
    let title: String
    let message: String
    let actions: [ActionType]
    let handler: (ActionType, [Fields.AllCases.Element: String]) -> Void
  }
}

protocol AlertFields {
  var text: String { get }
  var placeholder: String { get }
}

extension AlertFields {
  var text: String { .empty }
  var placeholder: String { .empty }
}
