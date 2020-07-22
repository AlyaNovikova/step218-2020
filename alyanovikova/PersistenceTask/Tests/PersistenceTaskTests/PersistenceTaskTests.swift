import XCTest
@testable import PersistenceTask

final class PersistenceTaskTests: XCTestCase {
  private var fileURL: URL!

  override func setUp() {
    super.setUp()
    do {
      let documentsDirectory = try FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true)
      fileURL = documentsDirectory.appendingPathComponent("TodoList")
    } catch {
      XCTFail("Test failed with \(error)")
    }
  }

  func testReadingFromFile() throws {
    try FileManager.default.removeItem(at: fileURL)
    do {
      let todos = [Todo(todo: "take a walk with dogs"), Todo(todo: "learn swift"), Todo(todo: "call mum")]

      let jsonEncoder = JSONEncoder()
      let data = try jsonEncoder.encode(todos)

      try data.write(to: fileURL)
    } catch {
      XCTFail("Test failed with \(error)")
    }

    let todoList = try TodoList()

    XCTAssert(FileManager.default.fileExists(atPath: fileURL.path))
    XCTAssert(todoList.todos.count == 3)
    XCTAssert(todoList.todos[0].todo == "take a walk with dogs" && todoList.todos[0].isCompleted == false)
    XCTAssert(todoList.todos[1].todo == "learn swift" && todoList.todos[0].isCompleted == false)
    XCTAssert(todoList.todos[2].todo == "call mum" && todoList.todos[0].isCompleted == false)
  }

  func testWritingToFile() throws {
    try FileManager.default.removeItem(at: fileURL)
    do {
      let todoList = try TodoList()
      try todoList.add(todo: Todo(todo: "get some sleep"))
      try todoList.add(todo: Todo(todo: "buy curd snack"))
      let _ = try todoList.changeStatus(of: 0, newStatus: true)
    } catch {
      XCTFail("Test failed with \(error)")
    }

    let data = try Data(contentsOf: fileURL)

    let jsonDecoder = JSONDecoder()
    let todos = try jsonDecoder.decode([Todo].self, from: data)

    XCTAssert(todos.count == 2)
    XCTAssert(todos[0].todo == "get some sleep" && todos[0].isCompleted == true)
    XCTAssert(todos[1].todo == "buy curd snack" && todos[1].isCompleted == false)
  }

  static var allTests = [
    ("testWritingToFile", testWritingToFile),
    ("testReadingFromFile", testReadingFromFile),
  ]
}
