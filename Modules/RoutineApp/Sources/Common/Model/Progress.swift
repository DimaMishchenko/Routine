import Foundation

struct Progress: Hashable {
  let goal: Goal
  let current: Int
  
  var percent: Double { Double(current) / Double(goal.rawValue) }
}

extension Progress {
  struct Goal: RawRepresentable, Hashable, ExpressibleByIntegerLiteral {
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
