import UIKit

extension UIControl {
  func on(
    _ events: UIControl.Event = .touchUpInside,
    _ action: @escaping () -> Void
  ) {
    events.elements().forEach {
      let action = Action(action)
      addTarget(action, action: #selector(Action.invoke), for: $0)
      actions[$0.rawValue] = action
    }
  }
}

// MARK: - Action
extension UIControl {
  private final class Action {
    private let action: () -> Void
    
    init(_ action: @escaping () -> Void) {
      self.action = action
    }
    
    @objc func invoke() { action() }
  }
  
  private enum AssociatedKey {
    static var actions = "uicontrol-actions"
  }
  
  private var actions: [UInt: Action] {
    get { objc_getAssociatedObject(self, &AssociatedKey.actions) as? [UInt: Action] ?? [:] }
    set { objc_setAssociatedObject(self, &AssociatedKey.actions, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }
}

// MARK: - OptionSet+Elementa
extension OptionSet where RawValue: FixedWidthInteger {
  fileprivate func elements() -> AnySequence<Self> {
    var remainingBits = rawValue
    var bitMask: RawValue = 1
    return AnySequence {
      AnyIterator {
        while remainingBits != 0 {
          defer { bitMask = bitMask &* 2 }
          if remainingBits & bitMask != 0 {
            remainingBits = remainingBits & ~bitMask
            return Self(rawValue: bitMask)
          }
        }
        return nil
      }
    }
  }
}
