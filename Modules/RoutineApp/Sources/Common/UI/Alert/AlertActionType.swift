import UIKit

extension Alert {
  enum ActionType {
    case ok
    case cancel
    case custom(Custom)
    
    var title: String {
      switch self {
      case .ok:                 return RoutineStrings.Alert.ok
      case .cancel:             return RoutineStrings.Alert.cancel
      case .custom(let action): return action.title
      }
    }
    
    var style: UIAlertAction.Style {
      switch self {
      case .ok:                 return .default
      case .cancel:             return .cancel
      case .custom(let action): return action.style
      }
    }
  }
}

extension Alert.ActionType {
  struct Custom: Hashable {
    let title: String
    let style: UIAlertAction.Style
  }
}
