import DeviceKit
import SwiftUI

struct RoutineDetailsView<VM: RoutineDetailsViewModel>: View {
  private enum ChartType: CaseIterable {
    case bar
    case line
  }
  
  @ObservedObject private var viewModel: VM
  @State private var chartType = ChartType.bar
  
  init(viewModel: VM) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    ScrollView {
      VStack(spacing: Inset.Padding.big) {
        // Overview
        Section(title: RoutineAppStrings.RoutineDetails.Section.overview, drawGroup: false) {
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
            ForEach(viewModel.statsVMs) {
              StatsView(viewModel: $0)
                .padding([.top, .bottom], Inset.Padding.default)
                .frame(maxWidth: .infinity)
                .background(
                  RoundedRectangle(cornerRadius: Size.CornerRadius.container, style: .continuous)
                    .fill(SwiftUI.Color(Color.Background.secondary))
                )
            }
          }
        }
        
        // Calendar
        if #available(iOS 16.0, *) {
          Section(title: RoutineAppStrings.RoutineDetails.Section.calendar, padding: Inset.Padding.small) {
            CalendarView(viewModel: viewModel.calendarVM)
              .frame(
                height: Device.current.realDevice.isOneOf(Device.allPlusSizedDevices) ?
                  430 :
                  (Device.current.isIPhoneMini ? 380 : 400)
              )
          }
        }
        
        // Charts
        Section(title: RoutineAppStrings.RoutineDetails.Section.charts) {
          VStack(spacing: Inset.Padding.default) {
            Picker("", selection: $chartType) {
              ForEach(ChartType.allCases, id: \.self) {
                switch $0 {
                case .bar:
                  Text(RoutineAppStrings.RoutineDetails.Text.Chart.bar)
                case .line:
                  Text(RoutineAppStrings.RoutineDetails.Text.Chart.line)
                }
              }
            }
            .pickerStyle(.segmented)
            
            switch chartType {
            case .bar:
              BarChart(viewModel: viewModel.barChartVM)
                .frame(width: .infinity, height: 218)
            case .line:
              LineChart(viewModel: viewModel.lineChartVM)
                .frame(width: .infinity, height: 218)
            }
          }
        }
        
        // Success rate
        Section(title: RoutineAppStrings.RoutineDetails.Section.successRate) {
          VStack(spacing: Inset.Padding.small) {
            CircularProgressSUIView(progress: viewModel.successRate, lineWidth: 30)
              .frame(width: 202, height: 202)
            
            HStack {
              Circle()
                .fill(
                  LinearGradient(
                    colors: Color.Gradient.primary
                      .compactMap { $0 }
                      .map { SwiftUI.Color($0) },
                    startPoint: .top,
                    endPoint: .bottom
                  )
                )
                .frame(width: 8, height: 8)
              
              Text(RoutineAppStrings.RoutineDetails.Text.completedRoutines)
                .foregroundColor(SwiftUI.Color(Color.Text.value))
                .font(Font.system(size: .body, weight: .regular))
            }
          }
          .frame(maxWidth: .infinity)
        }
      }
      .padding(Inset.Padding.default)
    }
    .background(SwiftUI.Color(Color.Background.default))
    .onAppear { viewModel.loadDetails() }
  }

  private struct Section<Content>: View where Content: View {
    let title: String
    let drawGroup: Bool
    let padding: CGFloat
    @ViewBuilder let content: () -> Content
    
    init(
      title: String,
      drawGroup: Bool = true,
      padding: CGFloat = Inset.Padding.default,
      @ViewBuilder content: @escaping () -> Content
    ) {
      self.title = title
      self.drawGroup = drawGroup
      self.padding = padding
      self.content = content
    }
    
    var body: some View {
      VStack(spacing: .zero) {
        Text(title.uppercased())
          .foregroundColor(SwiftUI.Color(Color.Text.header))
          .font(Font.system(size: .caption1, weight: .semibold))
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.leading, Inset.Padding.default)
        
        Spacer(minLength: Inset.Padding.small)
        
        if !drawGroup {
          content()
        } else {
          content()
            .padding(padding)
            .background(
              RoundedRectangle(cornerRadius: Size.CornerRadius.container, style: .continuous)
                .fill(SwiftUI.Color(Color.Background.secondary))
            )
        }
      }
    }
  }
}

#if DEBUG
// MARK: - Preview
struct RoutineDetailsView_Previews: PreviewProvider {
  private final class VMMock: RoutineDetailsViewModel {
    var description: String = "Description"
    
    var statsVMs: [StatsViewModel] = [
      .init(image: RoutineAppAsset.Icon.bestStreak.image, title: "Title", description: "Description"),
      .init(image: RoutineAppAsset.Icon.bestStreak.image, title: "Title", description: "Description"),
      .init(image: RoutineAppAsset.Icon.bestStreak.image, title: "Title", description: "Description"),
      .init(image: RoutineAppAsset.Icon.bestStreak.image, title: "Title", description: "Description")
    ]
    
    var calendarVM: CalendarVM = .init(
      selections: [
        .init(emoji: "🖼", date: Date()),
        .init(emoji: "🖼", date: Date().byAddingDay ?? Date()),
        .init(emoji: "🖼", date: Date().byAddingWeek ?? Date())
      ]
    )
    
    var barChartVM: BarChartVM = .init(
      entries: [
        .init(title: "1", value: 1),
        .init(title: "2", value: 2),
        .init(title: "3", value: 3)
      ]
    )
    
    var lineChartVM: LineChartVM = .init(
      entries: [
        .init(title: "1", value: 1),
        .init(title: "2", value: 2),
        .init(title: "3", value: 3)
      ]
    )
    
    var successRate: Double = 0.5
    
    func close() {}
    func edit() {}
    func loadDetails() {}
  }
  
  static var previews: some View {
    NavigationView {
      RoutineDetailsView(
        viewModel: VMMock()
      )
      .navigationTitle("Details")
    }
  }
}
#endif
