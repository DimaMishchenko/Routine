import Foundation

struct Progress {
  let goal: Goal
  let current: Int
}

extension Progress {
  struct Goal: RawRepresentable, ExpressibleByIntegerLiteral {
    static let min: Goal = 1
    static let max: Goal = 7
    
    let rawValue: Int
    
    init(rawValue: Int) {
      self.rawValue = rawValue
    }
    
    init(integerLiteral value: Int) {
      rawValue = value
    }
  }
}
