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
}
