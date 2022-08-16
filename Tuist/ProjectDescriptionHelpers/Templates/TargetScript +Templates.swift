import ProjectDescription

extension TargetScript {
  public static var swiftlint: TargetScript {
    .post(
      script: """
      export PATH="$PATH:/opt/homebrew/bin"
      if which swiftlint >/dev/null; then
        swiftlint
      else
        echo "warning: SwiftLint not installed"
      fi
      """,
      name: "SwiftLint"
    )
  }
  
  public static var crashlytics: TargetScript {
    .post(
      script: "${PROJECT_DIR}/Tuist/Dependencies/SwiftPackageManager/.build/checkouts/firebase-ios-sdk/Crashlytics/run -gsp ${PROJECT_DIR}/Modules/RoutineApp/Resources/FirebaseConfig/${GOOGLE_SERVICE_INFO_NAME}.plist",
      name: "Crashlytics"
    )
  }
}
