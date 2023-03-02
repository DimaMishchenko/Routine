import AppIntents

// MARK: - AppDependencyManager + Key
@available(iOS 16.0, *)
extension AppDependencyManager {
  struct Key<Dependency>: Identifiable, Hashable, Equatable {
    let id = String(describing: Dependency.self)
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
  }
}

// MARK: - AppDependencyManager + Add for Key
@available(iOS 16.0, *)
extension AppDependencyManager {
  final func add<Dependency>(
    _ type: Dependency.Type,
    dependency: @escaping () throws -> Dependency?
  ) where Dependency: Sendable {
    add(key: AppDependencyManager.Key<Dependency>(), dependency: dependency)
    add(key: AppDependencyManager.Key<Dependency?>(), dependency: dependency)
  }

  final func add<Dependency>(
    _ type: Dependency.Type,
    dependency: @escaping () async throws -> Dependency?
  ) where Dependency: Sendable {
    add(key: AppDependencyManager.Key<Dependency>(), dependency: dependency)
    add(key: AppDependencyManager.Key<Dependency?>(), dependency: dependency)
  }
}

// MARK: - AppDependency + Init
@available(iOS 16.0, *)
extension AppDependency {
  convenience init(
    manager: AppDependencyManager = .shared,
    default defaultValueProvider: @autoclosure @escaping () -> Value
  ) {
    self.init(key: AppDependencyManager.Key<Value>(), manager: manager, default: defaultValueProvider)
  }

  convenience init(
    manager: AppDependencyManager = .shared,
    default defaultValueProvider: @escaping () async throws -> Value
  ) {
    self.init(key: AppDependencyManager.Key<Value>(), manager: manager, default: defaultValueProvider)
  }
}

@available(iOS 16.0, *)
extension AppDependency where Value: ExpressibleByNilLiteral {
  convenience init(manager: AppDependencyManager = .shared) {
    self.init(key: AppDependencyManager.Key<Value>(), manager: manager, default: nil)
  }
}
