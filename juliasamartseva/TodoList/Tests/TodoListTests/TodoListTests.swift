import XCTest

@testable import TodoList

final class TodoListTests: XCTestCase {
  private var fileURL: URL!

  override func setUpWithError() throws {
    /// Removing file if it exists before each test.
    fileURL = try TaskListManager.makeDefaultURL()
    if FileManager.default.fileExists(atPath: fileURL.path) {
      try FileManager.default.removeItem(at: fileURL)
    }
  }

  func testEmptyTaskListCreation() throws {
    // GIVEN
    let taskList = try TaskListManager()

    // WHEN
    XCTAssert(taskList.tasks.isEmpty)
    XCTAssertEqual(FileManager.default.contents(atPath: fileURL.path), nil)
  }

  func testAddTask() throws {
    // GIVEN
    let taskList = try TaskListManager()

    // WHEN
    try taskList.add(task: Task(name: "Notes", description: "description", isDone: true))

    // THEN
    let loadedTaskList = try [Task](jsonFileURL: fileURL)
    XCTAssertEqual(loadedTaskList, taskList.tasks)
  }

  func testChangingCompletionStatus() throws {
    // GIVEN
    let taskList = try TaskListManager()
    try taskList.add(task: Task(name: "Notes", description: "description", isDone: false))
    try taskList.add(task: Task(name: "Hello world", description: "description", isDone: true))

    // WHEN
    try taskList.changeCompletion(at: 0, to: true)
    try taskList.changeCompletion(at: 1, to: false)

    // THEN
    let loadedTaskList = try [Task](jsonFileURL: taskList.fileURL)
    XCTAssert(loadedTaskList[0].isDone)
    XCTAssertFalse(loadedTaskList[1].isDone)
  }

  func testNotEmptyInitialization() throws {
    // GIVEN
    let task = Task(name: "Notes", description: "description", isDone: false)
    let data = try JSONEncoder().encode([task])
    try data.write(to: fileURL)

    // WHEN
    let taskList = try TaskListManager()

    // THEN
    XCTAssertEqual(taskList.tasks, [task])
  }

  func testInitializationFromCorruptedFile() throws {
    // GIVEN
    let data = "data".data(using: .utf8)!

    // WHEN
    try data.write(to: fileURL)
    XCTAssertThrowsError(try TaskListManager())
  }

  func testLoadedList() throws {
    // GIVEN
    let task = Task(name: "Notes", description: "description", isDone: false)
    let data = try JSONEncoder().encode([task])
    try data.write(to: fileURL)
    let taskList = try TaskListManager()
    let fileContents = try Data(contentsOf: taskList.fileURL)

    // WHEN
    let loadedTaskList = try [Task](jsonFileURL: taskList.fileURL)

    // THEN
    XCTAssertEqual(try JSONDecoder().decode([Task].self, from: fileContents), loadedTaskList)
  }

}
