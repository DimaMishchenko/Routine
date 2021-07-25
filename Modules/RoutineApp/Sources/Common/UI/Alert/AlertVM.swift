import Foundation

extension Alert {
  struct VM {
    let title: String
    let message: String
    let actions: [ActionType]
    let handler: (ActionType) -> Void
  }
}
