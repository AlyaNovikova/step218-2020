import XCTest

@testable import Contacts

final class ContactsTests: XCTestCase {
  private var fileURL: URL!

  override func setUpWithError() throws {
    fileURL = try ContactBook.makeDefaultURL()
    if FileManager.default.fileExists(atPath: fileURL.path) {
      try FileManager.default.removeItem(at: fileURL)
    }
  }

  func testInitialization() throws {
    _ = try ContactBook()

  }

  func testNotEmptyInitialization() throws {
    // GIVEN
    do {
      let contacts = [
        1: Contact(id: 1, name: "name1", surname: "surname1", phone: "+1"),
        2: Contact(id: 2, name: "name2", surname: "surname2", phone: "+2"),
      ]
      let list = ContactList(contacts: contacts, lastId: 2)

      let jsonEncoder = JSONEncoder()
      let data = try jsonEncoder.encode(list)

      try data.write(to: fileURL)
    }

    // WHEN
    let book = try ContactBook()

    // THEN
    XCTAssert(FileManager.default.fileExists(atPath: fileURL.path))
    XCTAssertEqual(book.contacts.count, 2)

    guard let contact1 = book.contacts[1] else {
      throw ContactBook.ContactError.nonexistentId
    }
    XCTAssertEqual(contact1.id, 1)
    XCTAssertEqual(contact1.name, "name1")
    XCTAssertEqual(contact1.surname, "surname1")
    XCTAssertEqual(contact1.phone, "+1")

    guard let contact2 = book.contacts[2] else {
      throw ContactBook.ContactError.nonexistentId
    }
    XCTAssertEqual(contact2.id, 2)
    XCTAssertEqual(contact2.name, "name2")
    XCTAssertEqual(contact2.surname, "surname2")
    XCTAssertEqual(contact2.phone, "+2")
  }

  func testAddUpdateRemoveContact() throws {
    // WHEN
    do {
      let book = try ContactBook()
      _ = try book.addContact(name: "Alya", surname: "Nov", phone: "+7911")
      _ = try book.addContact(name: "Juliaaaaa", surname: "Sam", phone: "+3800")
      _ = try book.addContact(name: "Nil", surname: "Nil", phone: "Nil")
    }

    // THEN
    do {
      let book = try ContactBook()

      XCTAssertEqual(book.contacts.count, 3)

      guard let contactAlya = book.contacts[1] else {
        throw ContactBook.ContactError.nonexistentId
      }
      XCTAssertEqual(contactAlya.id, 1)
      XCTAssertEqual(contactAlya.name, "Alya")
      XCTAssertEqual(contactAlya.surname, "Nov")
      XCTAssertEqual(contactAlya.phone, "+7911")
    }

    // WHEN
    do {
      let book = try ContactBook()

      try book.updateContact(
        newContact: Contact(id: 2, name: "Julia", surname: "Sam", phone: "+3800"))
      try book.updateContact(
        newContact: Contact(id: 3, name: "Ira", surname: "Hor", phone: "+3801"))
    }

    // THEN
    do {
      let book = try ContactBook()

      guard let contactJulia = book.contacts[2] else {
        throw ContactBook.ContactError.nonexistentId
      }
      XCTAssertEqual(contactJulia.name, "Julia")

      guard let contactIra = book.contacts[3] else {
        throw ContactBook.ContactError.nonexistentId
      }
      XCTAssertEqual(contactIra.name, "Ira")

      XCTAssertEqual(
        book.listContacts(where: {
          guard $0.phone.count > 0 else {
            return false
          }
          return $0.phone[$0.phone.startIndex] == "+"
        }).count, 3)
    }

    // WHEN
    do {
      let book = try ContactBook()
      try book.removeContact(id: 1)
    }

    // THEN
    do {
      let book = try ContactBook()

      XCTAssertNil(book.contacts[1])
      XCTAssertEqual(
        book.listContacts(where: {
          guard $0.phone.count > 0 else {
            return false
          }
          return $0.phone[$0.phone.startIndex] == "+"
        }).count, 2)
    }
  }
}
