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
    let man1 = Contact(name: "name1", surname: "surname1", phone: "+1")
    let man2 = Contact(name: "name2", surname: "surname2", phone: "+2")

    do {
      let contacts = [
        man1.id: man1,
        man2.id: man2,
      ]

      let jsonEncoder = JSONEncoder()
      let data = try jsonEncoder.encode(contacts)

      try data.write(to: fileURL)
    }

    // WHEN
    let book = try ContactBook()

    // THEN
    XCTAssert(FileManager.default.fileExists(atPath: fileURL.path))
    XCTAssertEqual(book.contacts.count, 2)

    guard let contact1 = book.contacts[man1.id] else {
      throw ContactBook.ContactError.nonexistentId
    }
    XCTAssertEqual(contact1.id, man1.id)
    XCTAssertEqual(contact1.name, "name1")
    XCTAssertEqual(contact1.surname, "surname1")
    XCTAssertEqual(contact1.phone, "+1")

    guard let contact2 = book.contacts[man2.id] else {
      throw ContactBook.ContactError.nonexistentId
    }
    XCTAssertEqual(contact2.id, man2.id)
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
      guard let alya = book.listContacts(where: { $0.name == "Alya" }).first else {
        throw ContactBook.ContactError.noContact
      }

      XCTAssertEqual(book.contacts.count, 3)

      guard let contactAlya = book.contacts[alya.id] else {
        throw ContactBook.ContactError.nonexistentId
      }

      XCTAssertEqual(contactAlya.id, alya.id)
      XCTAssertEqual(contactAlya.name, "Alya")
      XCTAssertEqual(contactAlya.surname, "Nov")
      XCTAssertEqual(contactAlya.phone, "+7911")
    }

    // WHEN
    do {
      let book = try ContactBook()
      guard var julia = book.listContacts(where: { $0.name == "Juliaaaaa" }).first else {
        throw ContactBook.ContactError.noContact
      }
      guard var ira = book.listContacts(where: { $0.name == "Nil" }).first else {
        throw ContactBook.ContactError.noContact
      }
      julia.name = "Julia"
      ira.name = "Ira"
      ira.surname = "Hor"
      ira.phone = "+3801"

      try book.updateContact(
        newContact: julia)
      try book.updateContact(
        newContact: ira)
    }

    // THEN
    do {
      let book = try ContactBook()
      guard let julia = book.listContacts(where: { $0.name == "Julia" }).first else {
        throw ContactBook.ContactError.noContact
      }
      guard let ira = book.listContacts(where: { $0.name == "Ira" }).first else {
        throw ContactBook.ContactError.noContact
      }

      guard let contactJulia = book.contacts[julia.id] else {
        throw ContactBook.ContactError.nonexistentId
      }
      XCTAssertEqual(contactJulia.name, "Julia")

      guard let contactIra = book.contacts[ira.id] else {
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
      guard let alya = book.listContacts(where: { $0.name == "Alya" }).first else {
        throw ContactBook.ContactError.noContact
      }
      try book.removeContact(id: alya.id)
    }

    // THEN
    do {
      let book = try ContactBook()

      XCTAssertEqual(book.listContacts(where: { $0.name == "Alya" }).count, 0)
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
