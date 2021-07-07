import Foundation

final class AssemblyFactory {
  // MARK: - Dependencies
  private let serviceFactory: ServiceFactory
  
  // MARK: - Init
  init(serviceFactory: ServiceFactory) {
    self.serviceFactory = serviceFactory
  }
  
  // MARK: - Public
  func tabBarAssembly() -> TabBarAssembly {
    TabBarAssembly(assemblyFactory: self)
  }
}
