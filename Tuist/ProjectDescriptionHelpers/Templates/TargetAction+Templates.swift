import ProjectDescription

extension TargetAction {
  public static var swiftlint: TargetAction {
    .post(
      script: """
        if which swiftlint >/dev/null; then
          swiftlint
        else
          echo "warning: SwiftLint not installed, run `make init`"
        fi
      """,
      name: "SwiftLint"
    )
  }
  
  public static var crashlytics: TargetAction {
    .post(
      script: "${PODS_ROOT}/FirebaseCrashlytics/run -gsp ${PROJECT_DIR}/Modules/RoutineApp/Resources/FirebaseConfig/${GOOGLE_SERVICE_INFO_NAME}.plist",
      name: "Crashlytics"
    )
  }
}
