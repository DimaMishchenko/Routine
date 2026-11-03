@testable import Routine
import UIKit
import XCTest

@MainActor final class RoutineEditLayoutTests: XCTestCase {
  func testVisibleDeleteFooterReservesNonoverlappingViewport() throws {
    let editor = RoutineEditView()
    editor.updateDelete(visibility: true)
    let window = host(editor)
    defer { window.isHidden = true }

    try assertLayout(of: editor, footerIsVisible: true)
  }

  func testCreateModeUsesFullKeyboardLimitedViewport() throws {
    let editor = RoutineEditView()
    let window = host(editor)
    defer { window.isHidden = true }

    try assertLayout(of: editor, footerIsVisible: false)
  }

  func testFooterVisibilityUpdatesViewportAfterInitialLayout() throws {
    let editor = RoutineEditView()
    let window = host(editor)
    defer { window.isHidden = true }
    let collection = try collectionView(in: editor)
    let fullHeight = collection.bounds.height

    for isVisible in [true, false, true, false] {
      editor.updateDelete(visibility: isVisible)
      try assertLayout(of: editor, footerIsVisible: isVisible)
      if isVisible {
        XCTAssertLessThan(collection.bounds.height, fullHeight)
      } else {
        XCTAssertEqual(collection.bounds.height, fullHeight, accuracy: 1)
      }
    }
  }

  func testFooterViewportTracksWindowResizingAndSafeAreaChanges() throws {
    let editor = RoutineEditView()
    let window = host(editor)
    defer { window.isHidden = true }
    let host = try XCTUnwrap(window.rootViewController)

    let sizes = [
      CGSize(width: 844, height: 390), CGSize(width: 1024, height: 768),
      CGSize(width: 1280, height: 900), CGSize(width: 390, height: 844)
    ]
    for size in sizes {
      editor.updateDelete(visibility: true)
      window.frame.size = size
      for bottomInset in [CGFloat.zero, 34] {
        editor.updateDelete(visibility: true)
        host.additionalSafeAreaInsets.bottom = bottomInset
        window.setNeedsLayout()
        window.layoutIfNeeded()
        try assertLayout(of: editor, footerIsVisible: true)
        XCTAssertEqual(editor.bounds.width, size.width, accuracy: 1)
        XCTAssertEqual(editor.bounds.height, size.height, accuracy: 1)
        for isVisible in [true, false] {
          editor.updateDelete(visibility: isVisible)
          try assertLayout(of: editor, footerIsVisible: isVisible)
        }
      }
    }
  }

  private func host(_ editor: RoutineEditView) -> UIWindow {
    let host = UIViewController()
    host.view = editor
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
    window.rootViewController = host
    window.isHidden = false
    window.layoutIfNeeded()
    return window
  }

  private func collectionView(in editor: RoutineEditView) throws -> UICollectionView {
    try XCTUnwrap(editor.subviews.compactMap { $0 as? UICollectionView }.first)
  }

  private func assertLayout(
    of editor: RoutineEditView,
    footerIsVisible: Bool,
    file: StaticString = #filePath,
    line: UInt = #line
  ) throws {
    let collection = try collectionView(in: editor)
    let footer = try XCTUnwrap(editor.subviews.compactMap { $0 as? UIButton }.first)
    let bottomOffset = editor.safeAreaInsets.bottom == .zero ? Inset.Padding.default : editor.safeAreaInsets.bottom
    let keyboardTop = editor.keyboardLayoutGuide.layoutFrame.minY
    let viewportBottom = footerIsVisible ? min(keyboardTop, footer.frame.minY - Inset.Padding.small) : keyboardTop

    XCTAssertEqual(footer.isHidden, !footerIsVisible, file: file, line: line)
    XCTAssertEqual(collection.frame.minY, editor.bounds.minY, accuracy: 1, file: file, line: line)
    XCTAssertEqual(collection.frame.width, editor.bounds.width, accuracy: 1, file: file, line: line)
    XCTAssertGreaterThan(collection.bounds.height, 0, file: file, line: line)
    XCTAssertEqual(collection.frame.maxY, viewportBottom, accuracy: 1, file: file, line: line)
    XCTAssertLessThanOrEqual(collection.frame.maxY, keyboardTop + 1, file: file, line: line)
    XCTAssertEqual(collection.contentInset.bottom, Inset.Padding.default, accuracy: 1, file: file, line: line)
    XCTAssertEqual(footer.frame.height, Size.Button.big, accuracy: 1, file: file, line: line)
    XCTAssertEqual(footer.frame.maxY, editor.bounds.maxY - bottomOffset, accuracy: 1, file: file, line: line)
    XCTAssertEqual(footer.frame.midX, editor.bounds.midX, accuracy: 1, file: file, line: line)
    XCTAssertEqual(
      footer.frame.width,
      Size.View.contentWidth(for: editor.bounds.width) - 2 * Inset.Padding.default,
      accuracy: 1,
      file: file,
      line: line
    )
    if footerIsVisible {
      XCTAssertLessThanOrEqual(
        collection.frame.maxY, footer.frame.minY - Inset.Padding.small + 1, file: file, line: line
      )
      XCTAssertFalse(collection.frame.intersects(footer.frame), file: file, line: line)
    }
  }
}
