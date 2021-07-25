import Foundation

protocol ModelConfigurable {
  associatedtype Model: Hashable
  func update(with model: Model)
}
