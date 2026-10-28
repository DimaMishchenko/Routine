import MessageUI
import UIKit

final class MailAssembly {
  func controller(
    subject: String,
    message: String,
    addDebugData: Bool = false,
    onResult: @escaping (MFMailComposeResult, Error?) -> Void
  ) -> MailComposeController? {
    guard MFMailComposeViewController.canSendMail() else { return nil }

    let mailVC = MailComposeController {
      onResult($1, $2)
      $0.dismiss(animated: true)
    }

    mailVC.setToRecipients([AppConfiguration.contactEmail])
    mailVC.setSubject(subject)
    mailVC.setMessageBody(
      addDebugData ? (message + .newLine + debugInfo()) : message,
      isHTML: false
    )
    return mailVC
  }
  private func debugInfo() -> String {
    """

    Date: \(Date())
    Device: \(UIDevice.current.model)
    iOS version: \(UIDevice.current.systemVersion)
    App version: \(AppInfo.appVersion ?? .empty)
    """
  }
}

extension MailAssembly {
  final class MailComposeController: MFMailComposeViewController, MFMailComposeViewControllerDelegate {
    private let delegateProxy: (MFMailComposeViewController, MFMailComposeResult, Error?) -> Void
    fileprivate init(
      delegateProxy: @escaping (MFMailComposeViewController, MFMailComposeResult, Error?) -> Void
    ) {
      self.delegateProxy = delegateProxy
      super.init(nibName: nil, bundle: nil)

      mailComposeDelegate = self
    }

    @available(*, unavailable, message: "Not supported")
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    func mailComposeController(
      _ controller: MFMailComposeViewController,
      didFinishWith result: MFMailComposeResult,
      error: Error?
    ) {
      delegateProxy(controller, result, error)
    }
  }
}
