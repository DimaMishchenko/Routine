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
    switch type {
    case .routines: return UIViewController()
    case .settings: return UIViewController()
    }
  }
}
