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
    RoutineDetailsAssembly()
  }
  
  func appearance() -> AppearanceAssembly {
    AppearanceAssembly()
  }
}
