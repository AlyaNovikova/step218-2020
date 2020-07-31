import Foundation
import XCTest

@testable import Contacts

final class ContactsTests: XCTestCase {
  private var fileURL: URL!

  override func setUpWithError() throws {
    /// Removing file if it exists before each test.
    fileURL = try ContactList.makeDefaultURL()
    if FileManager.default.fileExists(atPath: fileURL.path) {
      try FileManager.default.removeItem(at: fileURL)
    }
  }

  func testContactInitialization() throws {
    /// The email must contain "@"
    XCTAssertThrowsError(
      try Contact(
        name: "name", phone: "380660989878", email: "hello.gmailcom", work: nil))

    /// The email must contain "."
    XCTAssertThrowsError(
      try Contact(
        name: "name", phone: "380660989878", email: "hello@gmailcom", work: nil))

    /// The email must contain something after "@"
    XCTAssertThrowsError(
      try Contact(
        name: "name", phone: "380660989878", email: "hello@.gmailcom", work: nil))

    /// The email must contain something before "@"
    XCTAssertThrowsError(
      try Contact(
        name: "name", phone: "380660989878", email: "@gmail.com", work: nil))

    /// The email must contain something after "."
    XCTAssertThrowsError(
      try Contact(
        name: "name", phone: "380660989878", email: "hello@gmailcom.", work: nil))

    /// The phone must contain 12 symbols
    XCTAssertThrowsError(
      try Contact(
        name: "name", phone: "566", email: "hello@gmail.com", work: nil))

    /// The given contact is of a valid format
    XCTAssertNotNil(
      try Contact(
        name: "name", phone: "380660989878", email: "hello@gmail.com", work: nil))
  }

  func testNotEmptyInitialization() throws {
    // GIVEN
    guard
      let sergii = try? Contact(
        name: "Sergii", phone: "380660989878", email: "df@g.com", work: nil)
    else {
      XCTFail("The contacts initialization throws error")
      return
    }
    let data = try JSONEncoder().encode([sergii])
    try data.write(to: fileURL)

    // WHEN
    let contactList = try ContactList()

    // THEN
    XCTAssertEqual(contactList.contacts, [sergii])
  }

  func testInitializationFromCorruptedFile() throws {
    // GIVEN
    let data = "data".data(using: .utf8)!

    // WHEN
    try data.write(to: fileURL)

    // THEN
    XCTAssertThrowsError(try ContactList())
  }

  func testEmptyContactListCreation() throws {
    // GIVEN
    let contactList = try ContactList()

    // WHEN
    XCTAssert(contactList.contacts.isEmpty)
    XCTAssertEqual(FileManager.default.contents(atPath: fileURL.path), nil)
  }

  func testFindContactByPredicate() throws {
    // GIVEN
    let contactList = try ContactList()
    guard
      let sergii = try? Contact(
        name: "Sergii", phone: "380660989878", email: "df@g.com",
        work: WorkInfo(jobTitle: "Translator", company: "X")),
      let lisa = try? Contact(
        name: "Lisa", phone: "380670989008", email: nil,
        work: WorkInfo(jobTitle: "Manager", company: "X")),
      let emma = try? Contact(
        name: "Emma", phone: "380470444403", email: "hello@gmail.com",
        work: WorkInfo(jobTitle: "Translator", company: nil))
    else {
      XCTFail("The contacts initialization throws error")
      return
    }
    try contactList.add(sergii)
    try contactList.add(lisa)
    try contactList.add(emma)

    // WHEN
    let contactsFromX = contactList.contacts { $0.work?.company == "X" }

    // THEN
    XCTAssert(contactsFromX.contains(sergii))
    XCTAssert(contactsFromX.contains(lisa))
  }

  func testFindContactById() throws {
    // GIVEN
    let contactList = try ContactList()
    guard
      let sergii = try? Contact(
        name: "Sergii", phone: "380660989878", email: "df@g.com",
        work: WorkInfo(jobTitle: "Translator", company: "X")),
      let lisa = try? Contact(
        name: "Lisa", phone: "380670989008", email: nil,
        work: WorkInfo(jobTitle: "Manager", company: "X")),
      let emma = try? Contact(
        name: "Emma", phone: "380470444403", email: "hello@gmail.com",
        work: WorkInfo(jobTitle: "Translator", company: nil))
    else {
      XCTFail("The contacts initialization throws error")
      return
    }
    try contactList.add(sergii)
    try contactList.add(lisa)
    try contactList.add(emma)
    let emmasId = emma.id

    // WHEN
    XCTAssertEqual(contactList.contact(withId: emmasId), emma)
  }

  func testAddContact() throws {
    // GIVEN
    let contactList = try ContactList()
    guard
      let sergii = try? Contact(
        name: "Sergii", phone: "380660989878", email: "df@g.com", work: nil)
    else {
      XCTFail("The contacts initialization throws error")
      return
    }

    // WHEN
    try contactList.add(sergii)

    // THEN
    let loadedContactList = try [Contact](jsonFileURL: fileURL)
    XCTAssertEqual(loadedContactList, contactList.contacts)
    XCTAssertEqual(loadedContactList, [sergii])
  }

  func testRemoveContact() throws {
    // GIVEN
    let contactList = try ContactList()
    guard
      let sergii = try? Contact(
        name: "Sergii", phone: "380660989878", email: "df@g.com", work: nil),
      let lisa = try? Contact(
        name: "Lisa", phone: "380670989008", email: nil,
        work: WorkInfo(jobTitle: "Manager", company: nil))
    else {
      XCTFail("The contacts initialization throws error")
      return
    }
    try contactList.add(sergii)
    try contactList.add(lisa)
    let sergiiId = sergii.id

    // WHEN
    try contactList.remove(sergii)

    // THEN
    let loadedContactList = try [Contact](jsonFileURL: fileURL)
    XCTAssertNil(contactList.contact(withId: sergiiId))
    XCTAssertFalse(loadedContactList.contains(sergii))
  }

  func testUpdateContact() throws {
    // GIVEN
    let contactList = try ContactList()
    guard
      var sergii = try? Contact(name: "Sergii", phone: "380660989878", email: "df@g.com", work: nil)
    else {
      XCTFail("The contacts initialization throws error")
      return
    }
    try contactList.add(sergii)

    // WHEN
    sergii.name = "Sergey"
    try contactList.update(contact: sergii)

    // THEN
    let updatedContact = contactList.contact(withId: sergii.id)
    XCTAssert(updatedContact!.name == "Sergey")
    let loadedContactList = try [Contact](jsonFileURL: fileURL)
    XCTAssert(loadedContactList.contains { $0.name == "Sergey" })
  }

  func testFindListSize() throws {
    // GIVEN
    let contactList = try ContactList()
    guard
      let sergii = try? Contact(
        name: "Sergii", phone: "380660989878", email: "df@g.com", work: nil),
      let lisa = try? Contact(
        name: "Lisa", phone: "380670989008", email: nil,
        work: WorkInfo(jobTitle: "Manager", company: nil))
    else {
      XCTFail("The contacts initialization throws error")
      return
    }

    // WHEN
    try contactList.add(sergii)
    XCTAssertEqual(contactList.size, 1)
    try contactList.add(lisa)
    XCTAssertEqual(contactList.size, 2)
    try contactList.remove(lisa)
    XCTAssertEqual(contactList.size, 1)
  }

}
