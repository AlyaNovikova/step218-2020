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

  enum ContactError: Error {
    case noContact
    case noGroup
    case nonexistentIdOfContact
    case nonexistentIdOfGroup
  }

  func testInitialization() throws {
    _ = try ContactBook()

  }

  func testNotEmptyInitialization() throws {
    // GIVEN
    let man1 = Contact(name: "name1", surname: "surname1", phone: "+1")
    let man2 = Contact(name: "name2", surname: "surname2", phone: "+2")

    let group1 = Group(title: "group1", members: [man1.id])

    do {
      let contacts = [
        man1.id: man1,
        man2.id: man2,
      ]
      let groups = [group1.id: group1]
      let groupsAndContacts = GroupsAndContacts(contacts: contacts, groups: groups)

      let jsonEncoder = JSONEncoder()
      let data = try jsonEncoder.encode(groupsAndContacts)

      try data.write(to: fileURL)
    }

    // WHEN
    let book = try ContactBook()

    // THEN
    XCTAssert(FileManager.default.fileExists(atPath: fileURL.path))
    XCTAssertEqual(book.contacts.count, 2)

    guard let contact1 = book.contacts[man1.id] else {
      throw ContactsTests.ContactError.nonexistentIdOfContact
    }
    XCTAssertEqual(contact1.id, man1.id)
    XCTAssertEqual(contact1.name, "name1")
    XCTAssertEqual(contact1.surname, "surname1")
    XCTAssertEqual(contact1.phone, "+1")

    guard let contact2 = book.contacts[man2.id] else {
      throw ContactsTests.ContactError.nonexistentIdOfContact
    }
    XCTAssertEqual(contact2.id, man2.id)
    XCTAssertEqual(contact2.name, "name2")
    XCTAssertEqual(contact2.surname, "surname2")
    XCTAssertEqual(contact2.phone, "+2")

    guard let group = book.groups[group1.id] else {
      throw ContactsTests.ContactError.nonexistentIdOfGroup
    }
    XCTAssertEqual(group.id, group1.id)
    XCTAssertEqual(group1.title, "group1")
    XCTAssertEqual(group.members.count, 1)
  }

  func testAddContact() throws {
    // WHEN
    do {
      let book = try ContactBook()
      _ = try book.addContact(name: "Alya", surname: "Nov", phone: "+7911")
      _ = try book.addContact(name: "Julia", surname: "Sam", phone: "+3800")
      _ = try book.addContact(name: "Ira", surname: "Hor", phone: "+3801")
    }

    // THEN
    do {
      let book = try ContactBook()
      guard let alya = book.listContacts(where: { $0.name == "Alya" }).first else {
        throw ContactsTests.ContactError.noContact
      }

      XCTAssertEqual(book.contacts.count, 3)

      guard let contactAlya = book.contacts[alya.id] else {
        throw ContactsTests.ContactError.nonexistentIdOfContact
      }

      XCTAssertEqual(contactAlya.id, alya.id)
      XCTAssertEqual(contactAlya.name, "Alya")
      XCTAssertEqual(contactAlya.surname, "Nov")
      XCTAssertEqual(contactAlya.phone, "+7911")
    }
  }

  func testUpdateContact() throws {
    // GIVEN
    do {
      let book = try ContactBook()
      _ = try book.addContact(name: "Alya", surname: "Nov", phone: "+7911")
      _ = try book.addContact(name: "Juliaaaaa", surname: "Sam", phone: "+3800")
      _ = try book.addContact(name: "Nil", surname: "Nil", phone: "Nil")
    }

    // WHEN
    do {
      let book = try ContactBook()
      guard var julia = book.listContacts(where: { $0.name == "Juliaaaaa" }).first else {
        throw ContactsTests.ContactError.noContact
      }
      guard var ira = book.listContacts(where: { $0.name == "Nil" }).first else {
        throw ContactsTests.ContactError.noContact
      }
      julia.name = "Julia"
      ira.name = "Ira"
      ira.surname = "Hor"
      ira.phone = "+3801"

      try book.updateContact(newContact: julia)
      try book.updateContact(newContact: ira)
    }

    // THEN
    do {
      let book = try ContactBook()
      guard let julia = book.listContacts(where: { $0.name == "Julia" }).first else {
        throw ContactsTests.ContactError.noContact
      }
      guard let ira = book.listContacts(where: { $0.name == "Ira" }).first else {
        throw ContactsTests.ContactError.noContact
      }

      guard let contactJulia = book.contacts[julia.id] else {
        throw ContactsTests.ContactError.nonexistentIdOfContact
      }
      XCTAssertEqual(contactJulia.name, "Julia")

      guard let contactIra = book.contacts[ira.id] else {
        throw ContactsTests.ContactError.nonexistentIdOfContact
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
  }

  func testRemoveContact() throws {
    // GIVEN
    do {
      let book = try ContactBook()
      _ = try book.addContact(name: "Alya", surname: "Nov", phone: "+7911")
      _ = try book.addContact(name: "Julia", surname: "Sam", phone: "+3800")
      _ = try book.addContact(name: "Ira", surname: "Hor", phone: "+3801")
    }

    // WHEN
    do {
      let book = try ContactBook()
      guard let alya = book.listContacts(where: { $0.name == "Alya" }).first else {
        throw ContactsTests.ContactError.noContact
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

  func testAddGroup() throws {
    // WHEN
    do {
      let book = try ContactBook()
      let man1 = try book.addContact(name: "name1", surname: "surname1", phone: "+1")
      let man2 = try book.addContact(name: "name2", surname: "surname2", phone: "+2")

      let friends = try book.addGroup(title: "Friends")
      let _ = try book.addGroup(title: "AllContacts", members: [man1.id, man2.id])

      try book.add(to: friends, contact: man1)
    }

    // THEN
    do {
      let book = try ContactBook()
      XCTAssertEqual(book.groups.count, 2)

      guard let group1 = book.groups.values.first(where: { $0.title == "Friends" }) else {
        throw ContactsTests.ContactError.noGroup
      }

      guard let group2 = book.groups.values.first(where: { $0.title == "AllContacts" }) else {
        throw ContactsTests.ContactError.noGroup
      }

      guard let friends = book.groups[group1.id] else {
        throw ContactsTests.ContactError.nonexistentIdOfGroup
      }

      guard let all = book.groups[group2.id] else {
        throw ContactsTests.ContactError.nonexistentIdOfGroup
      }

      XCTAssertEqual(friends.id, group1.id)
      XCTAssertEqual(friends.title, "Friends")
      XCTAssertEqual(friends.members.count, 1)

      XCTAssertEqual(all.id, group2.id)
      XCTAssertEqual(all.title, "AllContacts")
      XCTAssertEqual(all.members.count, 2)
    }
  }

  func testRemoveGroup() throws {
    // GIVEN
    do {
      let book = try ContactBook()
      let man1 = try book.addContact(name: "name1", surname: "surname1", phone: "+1")
      let man2 = try book.addContact(name: "name2", surname: "surname2", phone: "+2")

      let friends = try book.addGroup(title: "Friends")
      let _ = try book.addGroup(title: "AllContacts", members: [man1.id, man2.id])

      try book.add(to: friends, contact: man1)
    }

    // WHEN
    do {
      let book = try ContactBook()

      guard let friends = book.groups.values.first(where: { $0.title == "Friends" }) else {
        throw ContactsTests.ContactError.noGroup
      }

      try book.removeGroup(id: friends.id)
    }

    do {
      let book = try ContactBook()

      guard let man = book.listContacts(where: { $0.name == "name1" }).first else {
        throw ContactsTests.ContactError.noContact
      }

      guard let all = book.groups.values.first(where: { $0.title == "AllContacts" }) else {
        throw ContactsTests.ContactError.noGroup
      }

      try book.remove(from: all, contact: man)
    }

    // THEN
    do {
      let book = try ContactBook()
      XCTAssertEqual(book.groups.count, 1)

      XCTAssertNil(book.groups.values.first(where: { $0.title == "Friends" }))

      guard let group = book.groups.values.first(where: { $0.title == "AllContacts" }) else {
        throw ContactsTests.ContactError.noGroup
      }

      guard let all = book.groups[group.id] else {
        throw ContactsTests.ContactError.nonexistentIdOfGroup
      }
      XCTAssertEqual(all.id, group.id)
      XCTAssertEqual(all.title, "AllContacts")
      XCTAssertEqual(all.members.count, 1)
    }
  }

  func testMembers() throws {
    // GIVEN
    do {
      let book = try ContactBook()
      let man1 = try book.addContact(name: "name1", surname: "surname1", phone: "+1")
      let man2 = try book.addContact(name: "name2", surname: "surname2", phone: "+2")

      let friends = try book.addGroup(title: "Friends")
      let _ = try book.addGroup(title: "AllContacts", members: [man1.id, man2.id])

      try book.add(to: friends, contact: man1)
    }

    // THEN
    do {
      let book = try ContactBook()
      XCTAssertEqual(book.groups.count, 2)

      guard let friends = book.groups.values.first(where: { $0.title == "Friends" }) else {
        throw ContactsTests.ContactError.noGroup
      }

      guard let all = book.groups.values.first(where: { $0.title == "AllContacts" }) else {
        throw ContactsTests.ContactError.noGroup
      }

      guard let man1 = book.listContacts(where: { $0.name == "name1" }).first else {
        throw ContactsTests.ContactError.noContact
      }

      guard let man2 = book.listContacts(where: { $0.name == "name2" }).first else {
        throw ContactsTests.ContactError.noContact
      }

      try XCTAssertEqual(book.members(of: all), [man1, man2])
      try XCTAssertEqual(book.members(of: friends), [man1])

      try book.removeContact(id: man1.id)

      try XCTAssertEqual(book.members(of: all), [man2])
      try XCTAssertEqual(book.members(of: friends), [])
    }
  }
}
