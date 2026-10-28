import Foundation

final class AssemblyFactory {
  private let serviceFactory: ServiceFactory
  init(serviceFactory: ServiceFactory) {
    self.serviceFactory = serviceFactory
  }
  func navigationAssembly() -> NavigationAssembly {
    NavigationAssembly(assemblyFactory: self)
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
    RoutineEditAssembly(assemblyFactory: self, serviceFactory: serviceFactory)
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
}
