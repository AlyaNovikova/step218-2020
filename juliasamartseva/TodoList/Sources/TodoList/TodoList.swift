import Foundation

public struct Task: Codable, Equatable {
  public let name: String
  public let description: String
  public fileprivate(set) var isDone: Bool

  public init(name: String, description: String, isDone: Bool) {
    self.name = name
    self.description = description
    self.isDone = isDone
  }
}

public class TaskListManager {
  let fileURL: URL
  public internal(set) var tasks: [Task]

  public init() throws {
    fileURL = try Self.makeDefaultURL()
    do {
      tasks = try [Task](jsonFileURL: fileURL)
    } catch CocoaError.fileReadNoSuchFile {
      tasks = []
    }
  }

  public func add(task: Task) throws {
    tasks.append(task)
    try tasks.writeJSON(to: fileURL)
  }

  public func changeCompletion(at index: Int, to status: Bool) throws {
    guard index < tasks.count else {
      throw TaskListError.invalidIndex
    }
    tasks[index].isDone = status
    try tasks.writeJSON(to: fileURL)
  }

  static func makeDefaultURL() throws -> URL {
    let documentsDirectory = try FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true)
    return documentsDirectory.appendingPathComponent("tasks")
  }

}

enum TaskListError: Error {
  case invalidIndex
}

extension Encodable {
  func writeJSON(to fileURL: URL) throws {
    let data = try JSONEncoder().encode(self)
    try data.write(to: fileURL)
  }
}

extension Decodable {
  init(jsonFileURL: URL) throws {
    let data = try Data(contentsOf: jsonFileURL)
    self = try JSONDecoder().decode(Self.self, from: data)
  }
}
