import DGCharts
import Foundation
import SwiftUI

struct BarChartVM {
  let entries: [Entry]

  struct Entry {
    let title: String
    let value: Double
  }
}

struct BarChart: UIViewRepresentable {
  private let viewModel: BarChartVM
  init(viewModel: BarChartVM) {
    self.viewModel = viewModel
  }
  func makeUIView(context: Context) -> BarChartView {
    makeChart()
  }

  func makeChart() -> BarChartView {
    let chart = BarChartView()
    chart.renderer = Renderer(
      dataProvider: chart,
      animator: chart.chartAnimator,
      viewPortHandler: chart.viewPortHandler
    )
    return chart
  }
  
  func updateUIView(_ chart: BarChartView, context: Context) {
    apply(to: chart)
  }

  func apply(to chart: BarChartView) {
    chart.noDataText = RoutineAppStrings.Localizable.RoutineDetails.Text.Chart.noData
    guard viewModel.entries.count > 1 else {
      chart.clear()
      (chart.renderer as? BarLineScatterCandleBubbleRenderer)?.accessibleChartElements.removeAll()
      return
    }
    
    let dataEntries: [BarChartDataEntry] = viewModel.entries.enumerated().map {
      BarChartDataEntry(x: Double($0.offset), y: $0.element.value)
    }
    let chartDataSet = BarChartDataSet(entries: dataEntries)
    chartDataSet.colors = [Color.clear]
    chartDataSet.highlightEnabled = false
    chartDataSet.drawValuesEnabled = false
    let chartData = BarChartData(dataSet: chartDataSet)
    
    with(chart.xAxis) {
      $0.labelPosition = .bottom
      $0.labelFont = Font.system(.subhead, weight: .regular)
      $0.drawAxisLineEnabled = false
      $0.drawGridLinesEnabled = false
      $0.labelTextColor = Color.Text.default
      $0.labelCount = dataEntries.count
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
    
    chartData.barWidth = 0.25
    chart.pinchZoomEnabled = false
    chart.doubleTapToZoomEnabled = false
    chart.legend.enabled = false
    chart.data = chartData
    
    chart.gestureRecognizers?.forEach { $0.isEnabled = false }
  }
}

extension BarChart {
  final class Renderer: BarChartRenderer {
    override func drawDataSet(context: CGContext, dataSet: BarChartDataSetProtocol, index: Int) {
      super.drawDataSet(context: context, dataSet: dataSet, index: index)
      
      guard let buffers = Mirror(reflecting: self)
        .superclassMirror?
        .children
        .first(where: { $0.label == "_buffers" })?
        .value as? [[CGRect]]
      else {
        return
      }
      
      let buffer = buffers[index]
      
      buffer.forEach {
        context.saveGState()
        
        let path = UIBezierPath(roundedRect: $0, cornerRadius: Size.CornerRadius.barsInChart)
        let fillColors = Color.Gradient.secondary.map { $0?.cgColor }
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = fillColors as [Any]
        gradientLayer.bounds = $0
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        gradientLayer.mask = mask
        gradientLayer.render(in: context)
        context.restoreGState()
      }
    }
  }
}

#if DEBUG
struct BarChart_Previews: PreviewProvider {
  static var previews: some View {
    BarChart(
      viewModel: .init(
        entries: [
          .init(title: "Mon", value: 0),
          .init(title: "Tue", value: 1),
          .init(title: "Wed", value: 2),
          .init(title: "Thu", value: 2),
          .init(title: "Fri", value: 1),
          .init(title: "Sut", value: 3),
          .init(title: "Sun", value: 3)
        ]
      )
    )
      .frame(maxWidth: .infinity)
      .frame(height: 250)
      .padding()
  }
}
#endif
