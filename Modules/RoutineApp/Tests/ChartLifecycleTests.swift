import DGCharts
@testable import Routine
import UIKit
import XCTest

final class ChartLifecycleTests: XCTestCase {
  @MainActor func testBarChartClearsOldDataWhenHistoryDropsBelowTwoEntries() throws {
    let populated = BarChart(viewModel: BarChartVM(entries: [
      .init(title: "Tue", value: 1), .init(title: "Wed", value: 0)
    ]))
    let chart = populated.makeChart()
    populated.apply(to: chart)
    XCTAssertEqual(chart.data?.entryCount, 2)
    try seedAccessibility(of: chart)

    BarChart(viewModel: BarChartVM(entries: [.init(title: "Wed", value: 0)])).apply(to: chart)
    XCTAssertNil(chart.data)
    XCTAssertEqual(chart.accessibilityElementCount(), 0)

    populated.apply(to: chart)
    XCTAssertEqual(chart.data?.entryCount, 2)
    try seedAccessibility(of: chart)
    BarChart(viewModel: BarChartVM(entries: [])).apply(to: chart)
    XCTAssertNil(chart.data)
    XCTAssertEqual(chart.accessibilityElementCount(), 0)
  }

  @MainActor func testLineChartClearsOldDataWhenHistoryDropsBelowTwoEntries() throws {
    let populated = LineChart(viewModel: LineChartVM(entries: [
      .init(title: "Tue", value: 1), .init(title: "Wed", value: 0)
    ]))
    let chart = populated.makeChart()
    populated.apply(to: chart)
    XCTAssertEqual(chart.data?.entryCount, 2)
    try seedAccessibility(of: chart)

    LineChart(viewModel: LineChartVM(entries: [.init(title: "Wed", value: 0)])).apply(to: chart)
    XCTAssertNil(chart.data)
    XCTAssertEqual(chart.accessibilityElementCount(), 0)

    populated.apply(to: chart)
    XCTAssertEqual(chart.data?.entryCount, 2)
    try seedAccessibility(of: chart)
    LineChart(viewModel: LineChartVM(entries: [])).apply(to: chart)
    XCTAssertNil(chart.data)
    XCTAssertEqual(chart.accessibilityElementCount(), 0)
  }

  @MainActor private func seedAccessibility(of chart: ChartViewBase) throws {
    let renderer = try XCTUnwrap(chart.renderer as? BarLineScatterCandleBubbleRenderer)
    let element = NSUIAccessibilityElement(accessibilityContainer: chart)
    element.accessibilityLabel = "Tue 1, Wed 0"
    renderer.accessibleChartElements = [element]
    XCTAssertEqual(chart.accessibilityElementCount(), 1)
  }
}
