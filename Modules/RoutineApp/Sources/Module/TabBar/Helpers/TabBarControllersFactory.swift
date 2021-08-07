import UIKit

protocol TabBarControllersFactory {
  func controller(for type: TabBar.ItemType) -> UIViewController
}

final class TabBarControllersFactoryImpl: TabBarControllersFactory {
  // MARK: - Dependencies
  private let assemblyFactory: AssemblyFactory
  
  // MARK: - Init
  init(assemblyFactory: AssemblyFactory) {
    self.assemblyFactory = assemblyFactory
  }
   // MARK: - Public
  func controller(for type: TabBar.ItemType) -> UIViewController {
    UINavigationController(rootViewController: viewController(for: type))
  }
  
  // MARK: - Private
  private func viewController(for type: TabBar.ItemType) -> UIViewController {
    switch type {
    case .routines: return assemblyFactory.routineList().controller()
    case .settings: return assemblyFactory.settings().controller()
    }
  }
}
