import UIKit

final class AcknowledgementsVC: UIViewController {
  override func loadView() {
    let textView = UITextView()
    textView.isEditable = false
    textView.isSelectable = true
    textView.alwaysBounceVertical = true
    textView.backgroundColor = Color.Background.default
    textView.textColor = Color.Text.default
    textView.font = .preferredFont(forTextStyle: .body)
    textView.adjustsFontForContentSizeCategory = true
    textView.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 32, right: 16)
    textView.text = bundledAcknowledgements()
    view = textView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = RoutineAppStrings.Localizable.Acknowledgements.title
    navigationItem.largeTitleDisplayMode = .never
  }

  private func bundledAcknowledgements() -> String {
    guard let url = Bundle.main.url(forResource: "ThirdPartyAcknowledgements", withExtension: "txt") else {
      preconditionFailure("ThirdPartyAcknowledgements.txt must be bundled with Routine")
    }
    do {
      return try String(contentsOf: url, encoding: .utf8)
    } catch {
      preconditionFailure("Unable to read bundled acknowledgements: \(error)")
    }
  }
}
