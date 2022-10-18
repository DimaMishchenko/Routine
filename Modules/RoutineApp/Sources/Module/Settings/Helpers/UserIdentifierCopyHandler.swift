import Foundation
import UIKit.UIPasteboard

final class UserIdentifierCopyHandler {
  private var timer: Timer?
  private var counter: Int = .zero
  
  func appVersionSelected() {
    if timer == nil {
      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] _ in self?.reset() }
    }
    
    counter += 1
    
    if counter >= 3 {
      reset()
      UIPasteboard.general.string = UserIdentifier.current
      _ = [0][1]
    }
  }
  
  private func reset() {
    timer?.invalidate()
    timer = nil
    counter = .zero
  }
}
