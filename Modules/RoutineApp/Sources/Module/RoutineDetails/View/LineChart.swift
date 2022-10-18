import Charts
import Foundation
import SwiftUI

struct LineChartVM {
  let entries: [Entry]

  struct Entry {
    let title: String
    let value: Double
  }
}

struct LineChart: UIViewRepresentable {
  // MARK: - Constants
  private enum Constants {
    static let maxLabels = 4
  }
  
  // MARK: - Properties
  private let viewModel: LineChartVM
  
  // MARK: - Init
  init(viewModel: LineChartVM) {
    self.viewModel = viewModel
  }
  
  // MARK: - Public
  func makeUIView(context: Context) -> LineChartView {
    LineChartView()
  }
  
  func updateUIView(_ chart: LineChartView, context: Context) {
    chart.noDataText = RoutineAppStrings.RoutineDetails.Text.Chart.noData
    guard viewModel.entries.count > 1 else { return }
    
    let dataEntries: [ChartDataEntry] = viewModel.entries.enumerated().map {
      ChartDataEntry(x: Double($0.offset), y: $0.element.value)
    }
    let chartDataSet = with(LineChartDataSet(entries: dataEntries)) {
      $0.colors = Color.Gradient.secondary.compactMap { $0 }
      $0.highlightEnabled = false
      $0.drawValuesEnabled = false
      $0.drawCirclesEnabled = false
      $0.isDrawLineWithGradientEnabled = true
      $0.mode = .horizontalBezier
      $0.lineWidth = 4
      $0.gradientPositions = [.zero, CGFloat(viewModel.entries.map { $0.value }.max() ?? .zero)]
    }
    
    let chartData = LineChartData(dataSet: chartDataSet)
    
    with(chart.xAxis) {
      $0.labelPosition = .bottom
      $0.labelFont = Font.system(.subhead, weight: .regular)
      $0.drawAxisLineEnabled = false
      $0.drawGridLinesEnabled = false
      $0.labelTextColor = Color.Text.default
      $0.labelCount = dataEntries.count > Constants.maxLabels ? Constants.maxLabels : dataEntries.count
      $0.avoidFirstLastClippingEnabled = true
      $0.granularityEnabled = true
      $0.valueFormatter = DefaultAxisValueFormatter { [viewModel] value, _ in
        viewModel.entries[safe: Int(value)]?.title ?? ""
      }
    }
    
    with(chart.rightAxis) {
      $0.drawAxisLineEnabled = false
      $0.drawLabelsEnabled = false
      $0.drawGridLinesEnabled = false
    }
    
    with(chart.leftAxis) {
      $0.drawAxisLineEnabled = false
      $0.labelCount = dataEntries.count
      $0.labelTextColor = Color.Text.value
      $0.granularityEnabled = true
      $0.gridColor = Color.Separator.default
    }
    
    chart.pinchZoomEnabled = false
    chart.doubleTapToZoomEnabled = false
    chart.legend.enabled = false
    chart.data = chartData
    
    chart.gestureRecognizers?.forEach { $0.isEnabled = false }
  }
}

#if DEBUG
// MARK: - Preview
struct LineChart_Previews: PreviewProvider {
  static var previews: some View {
    LineChart(
      viewModel: .init(
        entries: [
          .init(title: "Mon", value: 00),
          .init(title: "Tue", value: 10),
          .init(title: "Wed", value: 20),
          .init(title: "Thu", value: 20),
          .init(title: "Fri", value: 10),
          .init(title: "Sut", value: 30),
          .init(title: "Sun", value: 30)
        ]
      )
    )
      .frame(width: .infinity, height: 250)
      .padding()
  }
}
#endif
