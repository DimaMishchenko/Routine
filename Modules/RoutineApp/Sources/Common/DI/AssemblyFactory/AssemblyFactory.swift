import Foundation

final class AssemblyFactory {
  // MARK: - Dependencies
  private let serviceFactory: ServiceFactory
  
  // MARK: - Init
  init(serviceFactory: ServiceFactory) {
    self.serviceFactory = serviceFactory
  }
  
  // MARK: - Public
  func navigationAssembly() -> NavigationAssembly {
    NavigationAssembly(assemblyFactory: self, serviceFactory: serviceFactory)
  }
  
  func settings() -> SettingsAssembly {
    SettingsAssembly(assemblyFactory: self, serviceFactory: serviceFactory)
  }
  
  func routineList() -> RoutineListAssembly {
    RoutineListAssembly(assemblyFactory: self, serviceFactory: serviceFactory)
  }
  
  func share() -> ShareAssembly {
    ShareAssembly()
  }
  
  func mail() -> MailAssembly {
    MailAssembly()
  }
  
  func routineEdit() -> RoutineEditAssembly {
    RoutineEditAssembly(serviceFactory: serviceFactory)
  }
  
  func routineDetails() -> RoutineDetailsAssembly {
    RoutineDetailsAssembly(serviceFactory: serviceFactory)
  }
  
  func cloudInfo() -> CloudInfoAssembly {
    CloudInfoAssembly()
  }
  
  func appearance() -> AppearanceAssembly {
    AppearanceAssembly()
  }
  
  func tutorial() -> TutorialAssembly {
    TutorialAssembly()
  }
  
  func blocker() -> BlockerAssembly {
    BlockerAssembly()
  }
  
  func premium() -> PremiumAssembly {
    PremiumAssembly(serviceFactory: serviceFactory)
  }
}
