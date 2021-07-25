import Foundation

public struct Once {
  public private(set) var called = false
  
  public mutating func once(_ action: () -> Void) {
    guard !called else { return }
    defer { called = true }
    action()
  }
}
