struct AppLockState {
  enum Phase {
    case locked
    case authenticating
    case unlocked
  }

  private(set) var phase = Phase.locked
  private(set) var isActive = false
  private(set) var protectionEnabled = false
  private var automaticAttemptAvailable = true
  private var generation = 0

  var blocksContent: Bool { protectionEnabled && phase != .unlocked }
  var shouldAuthenticateAutomatically: Bool {
    protectionEnabled && isActive && phase == .locked && automaticAttemptAvailable
  }

  mutating func configure(protectionEnabled: Bool) {
    if self.protectionEnabled != protectionEnabled {
      generation += 1
      phase = protectionEnabled ? .locked : .unlocked
      automaticAttemptAvailable = true
    }
    self.protectionEnabled = protectionEnabled
  }

  mutating func activate(protectionEnabled: Bool) {
    configure(protectionEnabled: protectionEnabled)
    isActive = true
  }

  mutating func deactivate(protectionEnabled: Bool) {
    configure(protectionEnabled: protectionEnabled)
    isActive = false
    if phase == .unlocked {
      phase = .locked
      automaticAttemptAvailable = true
    }
  }

  mutating func enterBackground() {
    isActive = false
    generation += 1
    phase = protectionEnabled ? .locked : .unlocked
    automaticAttemptAvailable = true
  }

  mutating func beginAuthentication() -> Int? {
    guard protectionEnabled, isActive, phase != .authenticating else { return nil }
    generation += 1
    phase = .authenticating
    automaticAttemptAvailable = false
    return generation
  }

  @discardableResult
  mutating func completeAuthentication(succeeded: Bool, generation: Int) -> Bool {
    guard generation == self.generation, phase == .authenticating else { return false }
    phase = succeeded && isActive ? .unlocked : .locked
    return true
  }
}
