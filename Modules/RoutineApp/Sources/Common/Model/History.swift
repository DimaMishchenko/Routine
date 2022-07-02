import Foundation

struct History: Hashable {
  let uuid: UUID
  let date: Date
  let goal: Int
  let result: Int
}
