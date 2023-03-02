import AppIntents

enum IntentDonationHandler {
  static func donateIncreaseProgress(for routine: Routine) {
    if #available(iOS 16.0, *) {
      Task(logError: true) {
        let intent = IncreaseRoutinesProgressIntent(routines: [routine])
        try await IntentDonationManager.shared.donate(
          intent: intent,
          result: .result(value: intent.routines, dialog: "intent.IRP.result.success")
        )
      }
    }
  }
  
  static func donateComplete(_ routine: Routine) {
    if #available(iOS 16.0, *) {
      Task(logError: true) {
        let intent = CompleteRoutinesIntent(routines: [routine])
        try await IntentDonationManager.shared.donate(
          intent: intent,
          result: .result(value: intent.routines, dialog: "intent.CR.result.success")
        )
      }
    }
  }
}
