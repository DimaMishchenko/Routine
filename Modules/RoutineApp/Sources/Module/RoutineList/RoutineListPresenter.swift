import Foundation

protocol RoutineListPresenter {
  func viewDidLoad()
}

final class RoutineListPresenterImpl: RoutineListPresenter {
  // MARK: - Dependencies
  weak var view: RoutineListViewInterface?
  
  // MARK: - RoutineListPresenter
  func viewDidLoad() {
    view?.update(
      with: .init(
        items: [
          .init(
            section: .daily,
            rows: [
              .init(
                header: .init(
                  model: .init(title: "Daily", accessory: .outlineDisclosure)
                ),
                open: true,
                rows: [
                  .init(.empty(.init(text: RoutineStrings.RoutineList.Row.Empty.text)))
                ]
              )
            ]
          ),
          .init(
            section: .weekly,
            rows: [
              .init(
                header: .init(
                  model: .init(title: "Weekly", accessory: .outlineDisclosure)
                ),
                rows: [
                  .init(.value(.init(title: "4"))),
                  .init(.value(.init(title: "5"))),
                  .init(.value(.init(title: "6")))
                ]
              )
            ]
          ),
          .init(
            section: .monthly,
            rows: [
              .init(
                header: .init(
                  model: .init(title: "Monthly", accessory: .outlineDisclosure)
                ),
                rows: [
                  .init(.value(.init(title: "7"))),
                  .init(.value(.init(title: "8"))),
                  .init(.value(.init(title: "9")))
                ]
              )
            ]
          )
        ]
      )
    )
  }
}
