import SwiftUI

struct RoutineDetailsView: View {
  private let viewModel: RoutineDetailsViewModel
  
  init(viewModel: RoutineDetailsViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    ScrollView {
      VStack {
        // Overview
        Text(RoutineAppStrings.RoutineDetails.Section.overview)
          .font(Font.system(size: .title3, weight: .semibold))
          .padding(.bottom, Inset.Padding.default)
        
        if !viewModel.description.isEmpty {
          Text(viewModel.description)
            .padding(Inset.Padding.default)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              RoundedRectangle(cornerRadius: Size.CornerRadius.container, style: .continuous)
                .fill(SwiftUI.Color(Color.Background.secondary))
            )
        }
        
        Spacer(minLength: Inset.Padding.default)
        
        // Stats
        LazyVGrid(
          columns: [GridItem(.flexible(), spacing: Inset.Padding.default), GridItem(.flexible())],
          spacing: Inset.Padding.default
        ) {
          ForEach(viewModel.statsModels) {
            StatsView(viewModel: $0)
              .padding([.top, .bottom], Inset.Padding.default)
              .frame(maxWidth: .infinity)
              .background(
                RoundedRectangle(cornerRadius: Size.CornerRadius.container, style: .continuous)
                  .fill(SwiftUI.Color(Color.Background.secondary))
              )
          }
        }
        
        Spacer(minLength: Inset.Padding.big)
        
        // Progress
        
      }
      .padding(Inset.Padding.default)
    }
    .background(SwiftUI.Color(Color.Background.default))
  }
}

#if DEBUG
// MARK: - Preview
struct RoutineDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    RoutineDetailsView(
      viewModel: RoutineDetailsViewModelImpl(
        routine: .init(
          uuid: UUID(),
          name: "Example",
          description: "Here",
          emoji: "🐬",
          startDate: Date(),
          frequency: .daily,
          progress: .init(goal: .min, current: .zero),
          remind: false,
          reminders: [],
          history: []
        )
      )
    )
  }
}
#endif
