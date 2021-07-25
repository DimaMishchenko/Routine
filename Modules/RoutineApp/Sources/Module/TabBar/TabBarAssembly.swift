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
    let presenter = TabBarPresenterImpl()
    let vc = TabBarVC(
      presenter: presenter,
      controllersFactory: TabBarControllersFactoryImpl(assemblyFactory: assemblyFactory)
    )
    presenter.view = vc
    
    return vc
  }
}
