import Foundation

public struct Todo: Equatable, Codable {
  public let todo: String
  public fileprivate(set) var isCompleted: Bool

  public init(todo: String, isCompleted: Bool = false) {
    self.todo = todo
    self.isCompleted = isCompleted
  }
}

public class TodoList: Codable {
  public internal(set) var todos = [Todo]()
  private let fileURL: URL

  public init() throws {
    fileURL = try Self.makeDefaultURL()
    do {
      todos = try [Todo](jsonFileURL: fileURL)
    } catch CocoaError.fileReadNoSuchFile {
      todos = []
    }
  }

  public func add(todo: Todo) throws {
    todos.append(todo)
    try todos.writeJSON(to: fileURL)
  }

  public func changeStatus(of item: Todo, newStatus: Bool) throws {
    for i in todos.indices {
      if item == todos[i] {
        todos[i].isCompleted = newStatus
      }
    }
    try todos.writeJSON(to: fileURL)
  }

  static func makeDefaultURL() throws -> URL {
    let documentsDirectory = try FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true)
    return documentsDirectory.appendingPathComponent("TodoList")
  }
}

extension Encodable {
  fileprivate func writeJSON(to fileURL: URL) throws {
    let data = try JSONEncoder().encode(self)
    try data.write(to: fileURL)
  }
}

extension Decodable {
  fileprivate init(jsonFileURL: URL) throws {
    let data = try Data(contentsOf: jsonFileURL)
    self = try JSONDecoder().decode(Self.self, from: data)
  }
}