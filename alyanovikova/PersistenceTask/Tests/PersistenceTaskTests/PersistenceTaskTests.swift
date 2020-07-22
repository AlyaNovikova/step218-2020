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

  func testTodoList() throws {
    do {
      let todos = [Todo(todo: "take a walk with dogs"), Todo(todo: "learn swift"), Todo(todo: "call mum")]

      let jsonEncoder = JSONEncoder()
      let data = try jsonEncoder.encode(todos)

      try data.write(to: fileURL)

      let todoList = try TodoList()

      XCTAssert(FileManager.default.fileExists(atPath: fileURL.path))
      XCTAssert(todoList.todos.count == 3)
    } catch {
      XCTFail("Test failed with \(error)")

    }
    do {
      let todoList = try TodoList()

      try todoList.add(todo: Todo(todo: "get some sleep"))
      try todoList.changeStatus(of: 0, newStatus: true)
    } catch {
      XCTFail("Test failed with \(error)")
    }

    do {
      let todoList = try TodoList()

      XCTAssert(todoList.todos.count == 4)
      XCTAssert(todoList.todos[0].isCompleted == true)
      XCTAssert(todoList.todos[1].isCompleted == false)
    } catch {
      XCTFail("Test failed with \(error)")
    }
  }

  static var allTests = [
    ("testTodoList", testTodoList),
  ]
}
