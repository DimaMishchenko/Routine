import DeviceKit
import MessageUI
import UIKit

final class MailAssembly {
  func controller(
    subject: String,
    message: String,
    addDebugData: Bool = false,
    onResult: @escaping (MFMailComposeResult, Error?) -> Void
  ) -> MailComposeControllerProxy? {
    guard MFMailComposeViewController.canSendMail() else { return nil }

    let mailVC = MFMailComposeViewController()
    mailVC.setToRecipients([Flag.contactEmail])
    mailVC.setSubject(subject)
    mailVC.setMessageBody(
      addDebugData ? (message + .newLine + debugInfo()) : message,
      isHTML: false
    )
    return MailComposeControllerProxy(controller: mailVC) {
      onResult($1, $2)
      $0.dismiss(animated: true)
    }
  }
  
  // MARK: - Private
  private func debugInfo() -> String {
    """
    
    
    Date: \(Date())
    Device: \(Device.current.description)
    iOS version: \(UIDevice.current.systemVersion)
    App version: \(AppInfo.appVersion ?? .empty)
    Identifier: \(UserIdentifier.current)
    """
  }
}

extension MailAssembly {
  final class MailComposeControllerProxy: NSObject, MFMailComposeViewControllerDelegate {
    // MARK: - Properties
    let controller: MFMailComposeViewController
    private let delegateProxy: (MFMailComposeViewController, MFMailComposeResult, Error?) -> Void
    
    // MARK: - Init
    fileprivate init(
      controller: MFMailComposeViewController,
      delegateProxy: @escaping (MFMailComposeViewController, MFMailComposeResult, Error?) -> Void
    ) {
      self.controller = controller
      self.delegateProxy = delegateProxy
      super.init()
      
      self.controller.mailComposeDelegate = self
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(
      _ controller: MFMailComposeViewController,
      didFinishWith result: MFMailComposeResult,
      error: Error?
    ) {
      delegateProxy(controller, result, error)
    }
  }
}
