import UIKit

extension Alert {
  enum ActionType {
    case ok
    case yes
    case cancel
    case remove
    case custom(Custom)
    
    var title: String {
      switch self {
      case .ok:                 return RoutineAppStrings.Localizable.Alert.ok
      case .yes:                return RoutineAppStrings.Localizable.Alert.yes
      case .cancel:             return RoutineAppStrings.Localizable.Alert.cancel
      case .remove:             return RoutineAppStrings.Localizable.Alert.remove
      case .custom(let action): return action.title
      }
    }
    
    var style: UIAlertAction.Style {
      switch self {
      case .ok:                 return .default
      case .yes:                return .default
      case .cancel:             return .cancel
      case .remove:             return .destructive
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
