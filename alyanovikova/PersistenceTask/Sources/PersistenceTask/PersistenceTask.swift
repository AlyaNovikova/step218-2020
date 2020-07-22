import Cocoa

struct Todo: Codable {
  let todo: String
  var isCompleted: Bool

  init(todo: String, isCompleted: Bool = false) {
    self.todo = todo
    self.isCompleted = isCompleted
  }
}

class TodoList: Codable {
  var todos = [Todo]()
  private let fileURL: URL

  init() throws {
    let fileManager = FileManager.default

    let documentsDirectory = try fileManager.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true)

    fileURL = documentsDirectory.appendingPathComponent("TodoList")

    if fileManager.fileExists(atPath: fileURL.path) {
      let data = try Data(contentsOf: fileURL)

      let jsonDecoder = JSONDecoder()
      let todos = try jsonDecoder.decode([Todo].self, from: data)

      self.todos = todos
    }
  }

  func add(todo: Todo) throws {
    todos.append(todo)

    let jsonEncoder = JSONEncoder()
    let data = try jsonEncoder.encode(todos)

    try data.write(to: fileURL)
  }

  func changeStatus(of index: Int, newStatus: Bool) throws {
    todos[index].isCompleted = newStatus

    let jsonEncoder = JSONEncoder()
    let data = try jsonEncoder.encode(todos)

    try data.write(to: fileURL)
  }
}
