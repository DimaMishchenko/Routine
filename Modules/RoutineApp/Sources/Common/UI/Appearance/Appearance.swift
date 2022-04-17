import UIKit

enum Appearance {
  static func setup() {
    UINavigationBar.appearance().prefersLargeTitles = true
    UINavigationBar.appearance().titleTextAttributes = [
      .font: Font.system(.headline, weight: .semibold)
    ]
    UINavigationBar.appearance().largeTitleTextAttributes = [
      .font: Font.system(.largeTitle, weight: .bold)
    ]
    UITabBarItem.appearance().setTitleTextAttributes(
      [.font: Font.system(.caption3, weight: .medium)],
      for: .normal
    )
    UIBarButtonItem.swizzleSetTitleTextAttributes()
  }
}

extension UIBarButtonItem {
  fileprivate static func swizzleSetTitleTextAttributes() {
    guard let oldMethod = class_getInstanceMethod(Self.self, #selector(setter: style)) else { return }
    guard let newMethod = class_getInstanceMethod(Self.self, #selector(setter: _style)) else { return }
    method_exchangeImplementations(oldMethod, newMethod)
  }
  
  @objc private var _style: UIBarButtonItem.Style {
    get {
      self._style
    }
    set {
      self._style = newValue
      
      switch newValue {
      case .done:
        setTitleTextAttributes([.font: Font.system(.body, weight: .semibold)], for: .normal)
      default:
        setTitleTextAttributes([.font: Font.system(.body, weight: .regular)], for: .normal)
      }
    }
  }
}
