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
    } catch {
      XCTFail("Test failed with \(error)")
    }

    // WHEN
    let todoList = try TodoList()

    // THEN
    XCTAssert(FileManager.default.fileExists(atPath: fileURL.path))
    XCTAssert(todoList.todos.count == 3)
    XCTAssert(todoList.todos[0].todo == "take a walk with dogs" && todoList.todos[0].isCompleted == false)
    XCTAssert(todoList.todos[1].todo == "learn swift" && todoList.todos[0].isCompleted == false)
    XCTAssert(todoList.todos[2].todo == "call mum" && todoList.todos[0].isCompleted == false)
  }
  
  func testAddAndChangeStatus() throws {
    // WHEN
    do {
      let todoList = try TodoList()
      try todoList.add(todo: Todo(todo: "get some sleep"))
      try todoList.add(todo: Todo(todo: "buy curd snack"))
      let _ = try todoList.changeStatus(of: 0, newStatus: true)
    } catch {
      XCTFail("Test failed with \(error)")
    }

    // THEN
    let data = try Data(contentsOf: fileURL)
    
    let jsonDecoder = JSONDecoder()
    let todos = try jsonDecoder.decode([Todo].self, from: data)
    
    XCTAssert(todos.count == 2)
    XCTAssert(todos[0].todo == "get some sleep" && todos[0].isCompleted == true)
    XCTAssert(todos[1].todo == "buy curd snack" && todos[1].isCompleted == false)
  }
}
