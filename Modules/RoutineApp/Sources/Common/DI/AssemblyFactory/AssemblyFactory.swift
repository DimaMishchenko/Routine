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
  
  func settings() -> SettingsAssembly {
    SettingsAssembly(assemblyFactory: self)
  }
  
  func routineList() -> RoutineListAssembly {
    RoutineListAssembly(assemblyFactory: self)
  }
  
  func share() -> ShareAssembly {
    ShareAssembly()
  }
  
  func mail() -> MailAssembly {
    MailAssembly()
  }
  
  func routineEdit() -> RoutineEditAssembly {
    RoutineEditAssembly()
  }
}
