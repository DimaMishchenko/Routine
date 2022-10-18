import Foundation

struct Progress: Hashable {
  let goal: Goal
  let current: Int
  
  var percent: Double { Double(current) / Double(goal.rawValue) }
}

extension Progress {
  struct Goal: RawRepresentable, Hashable, Strideable, ExpressibleByIntegerLiteral {
    static let min: Goal = 1
    static let max: Goal = 99
    
    let rawValue: Int
    
    init(rawValue: Int) {
      self.rawValue = rawValue
    }
    
    init(integerLiteral value: Int) {
      rawValue = value
    }
    
    func distance(to other: Progress.Goal) -> Int {
      rawValue.distance(to: other.rawValue)
    }
    
    func advanced(by number: Int) -> Progress.Goal {
      .init(rawValue: rawValue.advanced(by: number))
    }
  }
}
