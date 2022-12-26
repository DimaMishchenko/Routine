import SwiftUI

struct UIKitLabel: UIViewRepresentable {
  let configuration: (UILabel) -> Void

  func makeUIView(context: UIViewRepresentableContext<Self>) -> UILabel { UILabel() }
  func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<Self>) {
    configuration(uiView)
  }
}
