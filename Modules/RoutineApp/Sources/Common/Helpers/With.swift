// Adapted helper and documentation from Then by Suyeol Jeon.
// Source: https://github.com/devxoul/Then/blob/master/Sources/Then/Then.swift
// Full third-party notices: THIRD_PARTY_NOTICES.md and bundled ThirdPartyAcknowledgements.txt.
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Suyeol Jeon (xoul.kr)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
