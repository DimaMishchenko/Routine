import SwiftUI

struct StatsViewModel: Identifiable {
  let id = UUID()
  let image: UIImage
  let title: String
  let description: String
}

struct StatsView: View {
  private let viewModel: StatsViewModel
  
  init(viewModel: StatsViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    VStack(spacing: .zero) {
      SwiftUI.Image(uiImage: viewModel.image)
        .frame(width: Size.Icon.big, height: Size.Icon.big, alignment: .center)
        .padding(.bottom, Inset.Padding.default)
      Text(viewModel.title)
        .padding(.bottom, Inset.Padding.extraSmall)
        .font(Font.system(size: .body, weight: .semibold))
      Text(viewModel.description)
        .foregroundColor(SwiftUI.Color(Color.Text.value))
        .font(Font.system(size: .callout, weight: .regular))
    }
  }
}

#if DEBUG
// MARK: - Preview
struct StatsView_Previews: PreviewProvider {
  static var previews: some View {
    StatsView(
      viewModel: StatsViewModel(
        image: RoutineAppAsset.Icon.add.image,
        title: "4 days",
        description: "Total done"
      )
    )
  }
}
#endif
