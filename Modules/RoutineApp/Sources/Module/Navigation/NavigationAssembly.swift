import UIKit

final class NavigationAssembly {
  // MARK: - Dependencies
  private let assemblyFactory: AssemblyFactory
  
  // MARK: - Init
  init(assemblyFactory: AssemblyFactory) {
    self.assemblyFactory = assemblyFactory
  }
  
  // MARK: - Public
  @MainActor func controller() -> UIViewController {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return TabBarVC(
        viewModel: NavigationViewModelImpl(),
        controllersFactory: NavigationControllersFactoryImpl(assemblyFactory: assemblyFactory)
      )
    } else {
      return SplitVC(
        viewModel: NavigationViewModelImpl(),
        controllersFactory: NavigationControllersFactoryImpl(assemblyFactory: assemblyFactory)
      )
    }
  }
}
