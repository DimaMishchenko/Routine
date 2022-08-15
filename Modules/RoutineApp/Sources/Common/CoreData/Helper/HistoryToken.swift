import CoreData

struct HistoryToken: Codable {
  let token: NSPersistentHistoryToken
}

extension HistoryToken {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let data = try container.decode(Data.self)
    guard let token = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSPersistentHistoryToken.self, from: data) else {
      throw EncodingError.invalidValue(data, .init(codingPath: [], debugDescription: "Failed to unarchive object"))
    }
    self.token = token
  }
  
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    let data = try NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
    try container.encode(data)
  }
}
