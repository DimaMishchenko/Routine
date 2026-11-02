import UIKit

@MainActor protocol NavigationContentLayout {
  var navigationContentInset: CGFloat { get }
}

enum CommonAppearance {
  static func setup(for scene: UIWindowScene) {
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
    
#if targetEnvironment(macCatalyst)
    scene.titlebar?.titleVisibility = .hidden
    UINavigationBar.appearance().preferredBehavioralStyle = .pad
    scene.sizeRestrictions?.minimumSize = CGSize(width: 480, height: 560)
    scene.sizeRestrictions?.maximumSize = CGSize(width: 1000, height: 900)
#endif
  }
  
  static func setupTheme() {
    switch Theme.current {
    case .light:
      UIApplication.keyWindow?.overrideUserInterfaceStyle = .light
    case .dark:
      UIApplication.keyWindow?.overrideUserInterfaceStyle = .dark
    case .system:
      UIApplication.keyWindow?.overrideUserInterfaceStyle = .unspecified
    }
  }
}

extension UIBarButtonItem {
  fileprivate static func swizzleSetTitleTextAttributes() {
    guard let oldMethod = class_getInstanceMethod(Self.self, #selector(setter: style)) else { return }
    guard let newMethod = class_getInstanceMethod(Self.self, #selector(setter: __swizzledStyle)) else { return }
    method_exchangeImplementations(oldMethod, newMethod)
  }
  
  // swiftlint:disable:next identifier_name
  @objc private var __swizzledStyle: UIBarButtonItem.Style {
    get {
      self.__swizzledStyle
    }
    set {
      self.__swizzledStyle = newValue
      
      switch newValue {
      case .done:
        setTitleTextAttributes([.font: Font.system(.body, weight: .semibold)], for: .normal)
      default:
        setTitleTextAttributes([.font: Font.system(.body, weight: .regular)], for: .normal)
      }
    }
  }
}
