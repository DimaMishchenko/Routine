@testable import Routine
import UIKit
import XCTest

final class TextViewCellTests: XCTestCase {
  @MainActor func testReusedDescriptionCellRestoresSavedTextAndEmptyPlaceholder() throws {
    let cell = TextViewCell(frame: .zero)
    cell.update(with: .init(text: "Read a chapter before bed.", placeholder: "Description"))
    let textView = try XCTUnwrap(cell.contentView.subviews.compactMap { $0 as? UITextView }.first)
    let placeholder = try XCTUnwrap(textView.subviews.compactMap { $0 as? UILabel }.first)
    XCTAssertEqual(textView.text, "Read a chapter before bed.")
    XCTAssertTrue(placeholder.isHidden)

    cell.update(with: .init(text: "", placeholder: "Optional description"))
    XCTAssertEqual(textView.text, "")
    XCTAssertEqual(placeholder.text, "Optional description")
    XCTAssertFalse(placeholder.isHidden)

    cell.update(with: .init(text: "Stretch each morning.", placeholder: "Description"))
    XCTAssertEqual(textView.text, "Stretch each morning.")
    XCTAssertTrue(placeholder.isHidden)
  }

  @MainActor func testUnchangedDescriptionRefreshPreservesSelectionWithoutEmittingEdit() throws {
    let cell = TextViewCell(frame: .zero)
    let model = TextViewCellVM(text: "Keep this description.", placeholder: "Description")
    cell.update(with: model)
    let textView = try XCTUnwrap(cell.contentView.subviews.compactMap { $0 as? UITextView }.first)
    textView.selectedRange = NSRange(location: 5, length: 4)
    var edits: [String] = []
    cell.onTextChange = { edits.append($0) }

    cell.update(with: model)
    XCTAssertEqual(textView.selectedRange, NSRange(location: 5, length: 4))
    XCTAssertTrue(edits.isEmpty)
  }

  @MainActor func testEditingAndSavingAnotherFieldPreservesSavedDescription() throws {
    var routine = EditableRoutine(routine: .new)
    routine.name = "Read every day"
    routine.description = "Read a chapter before bed."
    let presenter = RoutineEditPresenterImpl(
      moduleType: .edit(routine.routine),
      itemFactory: RoutineEditItemFactoryImpl(),
      notificationsHandler: DescriptionNotificationsHandler()
    )
    let cell = TextViewCell(frame: .zero)
    let view = DescriptionEditView { model in cell.update(with: model) }
    presenter.view = view
    cell.onTextChange = { presenter.descriptionChanged($0) }
    var saved: Routine?
    presenter.saveRoutine = { saved = $0 }

    presenter.viewDidLoad()
    let textView = try XCTUnwrap(cell.contentView.subviews.compactMap { $0 as? UITextView }.first)
    XCTAssertEqual(textView.text, routine.description)
    presenter.goalChanged(3)
    XCTAssertEqual(textView.text, routine.description)
    presenter.save()
    XCTAssertEqual(saved?.description, routine.description)
    XCTAssertEqual(saved?.progress.goal, 3)

    textView.text = "Read two chapters before bed."
    cell.textViewDidChange(textView)
    presenter.goalChanged(4)
    presenter.save()
    XCTAssertEqual(saved?.description, "Read two chapters before bed.")
    XCTAssertEqual(saved?.progress.goal, 4)
  }
}

private final class DescriptionEditView: RoutineEditViewInterface {
  private let onDescription: (TextViewCellVM) -> Void

  init(onDescription: @escaping (TextViewCellVM) -> Void) {
    self.onDescription = onDescription
  }

  func update(title: String) {}
  func updateDelete(visibility isVisible: Bool) {}
  func showAlert(with viewModel: Alert.VM) {}
  func update(with snapshot: Snapshot<RoutineEdit.Section, RoutineEdit.Row>) {
    for row in snapshot.items.flatMap({ $0.rows }) {
      if case .textview(let model) = row.type { onDescription(model) }
    }
  }
}

private struct DescriptionNotificationsHandler: NotificationsHandler {
  func isAuthorized() async -> Bool { true }
  func request() async -> Bool { true }
  func reconcile(_ routines: [Routine]) async throws {}
  func clearDelivered() {}
}
