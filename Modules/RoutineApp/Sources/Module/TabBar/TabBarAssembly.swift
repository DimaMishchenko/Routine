import UIKit

final class TabBarAssembly {
  // MARK: - Dependencies
  private let assemblyFactory: AssemblyFactory
  
  // MARK: - Init
  init(assemblyFactory: AssemblyFactory) {
    self.assemblyFactory = assemblyFactory
  }
  
  // MARK: - Public
  func controller() -> UIViewController {
    TabBarVC(
      presenter: TabBarPresenterImpl(),
      controllersFactory: TabBarControllersFactoryImpl(assemblyFactory: assemblyFactory)
    )
  }
}
