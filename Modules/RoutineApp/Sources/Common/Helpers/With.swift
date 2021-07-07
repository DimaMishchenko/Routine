/// Makes it available to execute something with closures and copying the value types.
///
///     let frame = with(CGRect()) {
///       $0.origin.x = 10
///       $0.size.width = 100
///     }
///
///     let label = with(UILabel()) {
///       $0.textAlignment = .center
///       $0.textColor = UIColor.black
///       $0.text = "Hello, World!"
///     }
///
///     with(UserDefaults.standard) {
///       $0.set("devxoul", forKey: "username")
///       $0.set("devxoul@gmail.com", forKey: "email")
///       $0.synchronize()
///     }
///
///     var string = "foo"
///
///     with(&string) {
///       $0 = "bar"
///     }
///
///     print(string) // bar
///
@discardableResult
public func with<T>(_ item: T, _ block: (inout T) throws -> Void) rethrows -> T {
  var item = item
  try block(&item)
  return item
}

public func with<T>(_ item: inout T, _ block: (inout T) throws -> Void) rethrows {
  try block(&item)
}
