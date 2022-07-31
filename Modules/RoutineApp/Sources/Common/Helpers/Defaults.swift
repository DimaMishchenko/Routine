import Foundation

@propertyWrapper struct Defaults<Item: Codable> {
  // MARK: - Properties
  private let key: DefaultsKey
  private let initial: Item
  private let defaults: UserDefaults
  private let serializer: Serializer

  // MARK: - Init
  init(key: DefaultsKey, initial: Item, defaults: UserDefaults = .standard, serializer: Serializer = Serializer()) {
    self.key = key
    self.initial = initial
    self.defaults = defaults
    self.serializer = serializer
  }

  // MARK: - @propertyWrapper
  var wrappedValue: Item {
    get { serializer.deserialize(from: defaults.string(forKey: key.rawValue)) ?? initial }
    set { defaults.set(serializer.serialize(newValue), forKey: key.rawValue) }
  }
}

extension Defaults where Item: ExpressibleByNilLiteral {
  init(key: DefaultsKey, defaults: UserDefaults = .standard, serializer: Serializer = Serializer()) {
    self.init(key: key, initial: nil, defaults: defaults, serializer: serializer)
  }
}

struct DefaultsKey: RawRepresentable, Equatable, Hashable, ExpressibleByStringLiteral {
  // MARK: - Properties
  let rawValue: String

  // MARK: - Init
  init(rawValue: String) {
    self.rawValue = rawValue
  }

  init(_ value: String) {
    self.init(rawValue: value)
  }

  init(stringLiteral value: StringLiteralType) {
    self.init(rawValue: value)
  }
}

struct Serializer {
  // MARK: - Properties
  private let encoder: JSONEncoder
  private let decoder: JSONDecoder

  // MARK: - Init
  init(encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder()) {
    self.encoder = encoder
    self.decoder = decoder
  }

  // MARK: - Internal
  fileprivate func serialize<T: Encodable>(_ item: T?) -> String? {
    guard !(T.self == String.self) else { return item as? String }
    guard let item = item, let data = try? encoder.encode(item) else { return nil }
    return String(data: data, encoding: .utf8)
  }

  fileprivate func deserialize<T: Decodable>(from item: String?) -> T? {
    guard !(T.self == String.self) else { return item as? T }
    guard let item = item, let data = item.data(using: .utf8) else { return nil }
    return try? decoder.decode(T.self, from: data)
  }
}
