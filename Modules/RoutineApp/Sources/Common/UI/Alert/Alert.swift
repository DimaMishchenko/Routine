import UIKit

enum Alert {}

extension Alert {
  static func show(
    on vc: UIViewController,
    with viewModel: Alert.VM
  ) {
    let controller = UIAlertController(
      title: viewModel.title,
      message: viewModel.message,
      preferredStyle: .alert
    )

    viewModel.actions.forEach { action in
      controller.addAction(
        UIAlertAction(title: action.title, style: action.style) { _ in
          viewModel.handler(action)
        }
      )
    }

    DispatchQueue.main.async {
      vc.present(controller, animated: true)
    }
  }

  static func show<Fields: CaseIterable & AlertFields>(
    on vc: UIViewController,
    with viewModel: Alert.FiledsVM<Fields>
  ) {
    let controller = UIAlertController(
      title: viewModel.title,
      message: viewModel.message,
      preferredStyle: .alert
    )

    Fields.allCases.forEach { field in
      controller.addTextField {
        $0.text = field.text
        $0.placeholder = field.placeholder
      }
    }

    viewModel.actions.forEach { action in
      controller.addAction(
        UIAlertAction(title: action.title, style: action.style) { [weak controller] _ in
          let textFielsResults = Fields.allCases.enumerated().reduce(into: [Fields.AllCases.Element: String]()) {
            $0[$1.element] = controller?.textFields?[safe: $1.offset]?.text
          }

          viewModel.handler(action, textFielsResults)
        }
      )
    }

    vc.present(controller, animated: true)
  }
}
