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
}
