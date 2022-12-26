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
    let vm = NavigationViewModelImpl()
    let vc: UIViewController
    let controllersFactory = NavigationControllersFactoryImpl(assemblyFactory: assemblyFactory)

    if UIDevice.current.userInterfaceIdiom == .phone {
      vc = TabBarVC(viewModel: vm, controllersFactory: controllersFactory)
    } else {
      vc = SplitVC(viewModel: vm, controllersFactory: controllersFactory)
    }

    vm.showTutorial = { [weak vc, weak assemblyFactory] in
      guard let tutorial = assemblyFactory?.tutorial().controller() else { return }
      if UIDevice.current.userInterfaceIdiom == .phone {
        tutorial.modalPresentationStyle = .fullScreen
      }
      vc?.present(tutorial, animated: true)
    }

    return vc
  }
}
