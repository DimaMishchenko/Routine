@testable import Routine
import SwiftUI
import UIKit
import XCTest

@MainActor final class CalendarLayoutTests: XCTestCase {
  func testWideDetailsCalendarKeepsNativeGridSize() async throws {
    let host = UIHostingController(rootView: calendar(selections: []).frame(width: 532))
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 600, height: 900))
    window.rootViewController = host
    window.isHidden = false
    defer { window.isHidden = true }
    try await settle(host)

    let calendarView = try XCTUnwrap(findCalendar(in: host.view))
    let nativeSize = calendarView.intrinsicContentSize
    XCTAssertGreaterThan(calendarView.bounds.width, 0)
    XCTAssertLessThanOrEqual(calendarView.bounds.width, nativeSize.width + 1)
    XCTAssertGreaterThanOrEqual(calendarView.bounds.height, nativeSize.height - 1)
    XCTAssertEqual(calendarView.bounds.midX, nativeSize.width / 2, accuracy: 1)
  }

  func testHistoryRefreshPreservesCalendarSelectionControllerAndVisibleMonth() async throws {
    let host = UIHostingController(rootView: calendar(selections: []).frame(width: 532))
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 600, height: 900))
    window.rootViewController = host
    window.isHidden = false
    defer { window.isHidden = true }
    try await settle(host)

    let originalCalendar = try XCTUnwrap(findCalendar(in: host.view))
    let originalSelection = try XCTUnwrap(originalCalendar.selectionBehavior as? UICalendarSelectionMultiDate)
    originalCalendar.setVisibleDateComponents(DateComponents(year: 2025, month: 6), animated: false)
    let date = try XCTUnwrap(Calendar.app.date(from: DateComponents(year: 2025, month: 6, day: 12)))
    host.rootView = calendar(selections: [.init(emoji: "✅", date: date)]).frame(width: 532)
    try await settle(host)

    let updatedCalendar = try XCTUnwrap(findCalendar(in: host.view))
    XCTAssertTrue(updatedCalendar === originalCalendar)
    XCTAssertTrue(updatedCalendar.selectionBehavior === originalSelection)
    XCTAssertEqual(originalSelection.selectedDates.map(\.day), [12])
    XCTAssertEqual(updatedCalendar.visibleDateComponents.year, 2025)
    XCTAssertEqual(updatedCalendar.visibleDateComponents.month, 6)
  }

  private func calendar(selections: [CalendarVM.Selection]) -> CalendarView {
    CalendarView(viewModel: .init(selections: selections), onSelection: { _ in }, onDeselection: { _ in })
  }

  private func settle<Content: View>(_ host: UIHostingController<Content>) async throws {
    host.view.setNeedsLayout()
    host.view.layoutIfNeeded()
    try await Task.sleep(for: .milliseconds(100))
    host.view.layoutIfNeeded()
  }

  private func findCalendar(in view: UIView) -> UICalendarView? {
    if let calendar = view as? UICalendarView { return calendar }
    return view.subviews.lazy.compactMap { self.findCalendar(in: $0) }.first
  }
}
