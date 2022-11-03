import UIKit

protocol NavigationControllersFactory {
  func controller(for type: Navigation.ItemType) -> UIViewController
}

final class NavigationControllersFactoryImpl: NavigationControllersFactory {
  // MARK: - Dependencies
  private let assemblyFactory: AssemblyFactory
  private var controllers: [Navigation.ItemType: UIViewController] = [:]
  
  // MARK: - Init
  init(assemblyFactory: AssemblyFactory) {
    self.assemblyFactory = assemblyFactory
  }
   // MARK: - Public
  func controller(for type: Navigation.ItemType) -> UIViewController {
    if let controller = controllers[type] {
      return controller
    } else {
      let controller = UINavigationController(rootViewController: viewController(for: type))
      controllers[type] = controller
      return controller
    }
  }
  
  // MARK: - Private
  private func viewController(for type: Navigation.ItemType) -> UIViewController {
    switch type {
    case .home: return assemblyFactory.routineList().controller()
    case .settings: return assemblyFactory.settings().controller()
    }
  }
}
