import XCTest
@testable import PersistenceTask

final class PersistenceTaskTests: XCTestCase {
  private var fileURL: URL!

  override func setUpWithError() throws {
    fileURL = try TodoList.makeDefaultURL()
    if FileManager.default.fileExists(atPath: fileURL.path) {
      try FileManager.default.removeItem(at: fileURL)
    }
  }

  func testInitialization() throws {
    _ = try TodoList()
  }
  
  func testNotEmptyInitialization() throws {
    // GIVEN
    do {
      let todos = [Todo(todo: "take a walk with dogs"), Todo(todo: "learn swift"), Todo(todo: "call mum")]
      
      let jsonEncoder = JSONEncoder()
      let data = try jsonEncoder.encode(todos)
      
      try data.write(to: fileURL)
    }

    // WHEN
    let todoList = try TodoList()

    // THEN
    XCTAssert(FileManager.default.fileExists(atPath: fileURL.path))
    XCTAssertEqual(todoList.todos.count, 3)
    XCTAssertEqual(todoList.todos[0].todo, "take a walk with dogs")
    XCTAssertEqual(todoList.todos[1].todo, "learn swift")
    XCTAssertEqual(todoList.todos[2].todo, "call mum")

    XCTAssertFalse(todoList.todos[0].isCompleted)
    XCTAssertFalse(todoList.todos[1].isCompleted)
    XCTAssertFalse(todoList.todos[2].isCompleted)
  }
  
  func testAddAndChangeStatus() throws {
    // WHEN
    do {
      let todoList = try TodoList()
      try todoList.add(todo: Todo(todo: "get some sleep"))
      try todoList.add(todo: Todo(todo: "buy curd snack"))
      try todoList.changeStatus(of: Todo(todo: "get some sleep"), newStatus: true)
    }

    // THEN
    let data = try Data(contentsOf: fileURL)
    
    let jsonDecoder = JSONDecoder()
    let todos = try jsonDecoder.decode([Todo].self, from: data)
    
    XCTAssertEqual(todos.count, 2)
    XCTAssertEqual(todos[0].todo, "get some sleep")
    XCTAssertEqual(todos[1].todo, "buy curd snack")

    XCTAssertTrue(todos[0].isCompleted)
    XCTAssertFalse(todos[1].isCompleted)
  }
}
