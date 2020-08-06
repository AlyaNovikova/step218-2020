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

    let group1 = Group(title: "group1", contactIds: [man1.id])

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
      XCTFail("There is no contact with the given id")
      return
    }
    XCTAssertEqual(contact1.id, man1.id)
    XCTAssertEqual(contact1.name, "name1")
    XCTAssertEqual(contact1.surname, "surname1")
    XCTAssertEqual(contact1.phone, "+1")

    guard let contact2 = book.contacts[man2.id] else {
      XCTFail("There is no contact with the given id")
      return
    }
    XCTAssertEqual(contact2.id, man2.id)
    XCTAssertEqual(contact2.name, "name2")
    XCTAssertEqual(contact2.surname, "surname2")
    XCTAssertEqual(contact2.phone, "+2")

    guard let group = book.groups[group1.id] else {
      XCTFail("There is no group with the given id")
      return
    }
    XCTAssertEqual(group.id, group1.id)
    XCTAssertEqual(group1.title, "group1")
    XCTAssertEqual(group.contactIds.count, 1)
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
        XCTFail("There is no contact with name Alya")
        return
      }

      XCTAssertEqual(book.contacts.count, 3)

      guard let contactAlya = book.contacts[alya.id] else {
        XCTFail("There is no contact with the given id")
        return
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
        XCTFail("There is no contact with name Juliaaaaa")
        return
      }
      guard var ira = book.listContacts(where: { $0.name == "Nil" }).first else {
        XCTFail("There is no contact with name Nil")
        return
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
        XCTFail("There is no contact with name Julia")
        return
      }
      guard let ira = book.listContacts(where: { $0.name == "Ira" }).first else {
        XCTFail("There is no contact with name Ira")
        return
      }

      guard let contactJulia = book.contacts[julia.id] else {
        XCTFail("There is no contact with the given id")
        return
      }
      XCTAssertEqual(contactJulia.name, "Julia")

      guard let contactIra = book.contacts[ira.id] else {
        XCTFail("There is no contact with the given id")
        return
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
        XCTFail("There is no contact with name Alya")
        return
      }
      try book.removeContact(alya)
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
      let _ = try book.addGroup(title: "AllContacts", contacts: [man1, man2])

      try book.add(to: friends, contact: man1)
    }

    // THEN
    do {
      let book = try ContactBook()
      XCTAssertEqual(book.groups.count, 2)

      guard let group1 = book.groups.values.first(where: { $0.title == "Friends" }) else {
        XCTFail("There is no group with title Friends")
        return
      }

      guard let group2 = book.groups.values.first(where: { $0.title == "AllContacts" }) else {
        XCTFail("There is no group with title AllContacts")
        return
      }

      guard let friends = book.groups[group1.id] else {
        XCTFail("There is no group with the given id")
        return
      }

      guard let all = book.groups[group2.id] else {
        XCTFail("There is no group with the given id")
        return
      }

      XCTAssertEqual(friends.id, group1.id)
      XCTAssertEqual(friends.title, "Friends")
      XCTAssertEqual(friends.contactIds.count, 1)

      XCTAssertEqual(all.id, group2.id)
      XCTAssertEqual(all.title, "AllContacts")
      XCTAssertEqual(all.contactIds.count, 2)
    }
  }

  func testRemoveGroup() throws {
    // GIVEN
    do {
      let book = try ContactBook()
      let man1 = try book.addContact(name: "name1", surname: "surname1", phone: "+1")
      let man2 = try book.addContact(name: "name2", surname: "surname2", phone: "+2")

      let friends = try book.addGroup(title: "Friends")
      let _ = try book.addGroup(title: "AllContacts", contacts: [man1, man2])

      try book.add(to: friends, contact: man1)
    }

    // WHEN
    do {
      let book = try ContactBook()

      guard let friends = book.groups.values.first(where: { $0.title == "Friends" }) else {
        XCTFail("There is no group with title Friends")
        return
      }

      try book.removeGroup(friends)
    }

    do {
      let book = try ContactBook()

      guard let man = book.listContacts(where: { $0.name == "name1" }).first else {
        XCTFail("There is no contact with name name1")
        return
      }

      guard let all = book.groups.values.first(where: { $0.title == "AllContacts" }) else {
        XCTFail("There is no group with title AllContacts")
        return
      }

      try book.remove(from: all, contact: man)
    }

    // THEN
    do {
      let book = try ContactBook()
      XCTAssertEqual(book.groups.count, 1)

      XCTAssertNil(book.groups.values.first(where: { $0.title == "Friends" }))

      guard let group = book.groups.values.first(where: { $0.title == "AllContacts" }) else {
        XCTFail("There is no group with title AllContacts")
        return
      }

      guard let all = book.groups[group.id] else {
        XCTFail("There is no group with the given id")
        return
      }
      XCTAssertEqual(all.id, group.id)
      XCTAssertEqual(all.title, "AllContacts")
      XCTAssertEqual(all.contactIds.count, 1)
    }
  }

  func testMembersOfGroup() throws {
    // GIVEN
    do {
      let book = try ContactBook()
      let man1 = try book.addContact(name: "name1", surname: "surname1", phone: "+1")
      let man2 = try book.addContact(name: "name2", surname: "surname2", phone: "+2")

      let friends = try book.addGroup(title: "Friends")
      let _ = try book.addGroup(title: "AllContacts", contacts: [man1, man2])

      try book.add(to: friends, contact: man1)
    }

    // THEN
    do {
      let book = try ContactBook()
      XCTAssertEqual(book.groups.count, 2)

      guard let friends = book.groups.values.first(where: { $0.title == "Friends" }) else {
        XCTFail("There is no group with title Friends")
        return
      }

      guard let all = book.groups.values.first(where: { $0.title == "AllContacts" }) else {
        XCTFail("There is no group with title AllContacts")
        return
      }

      guard let man1 = book.listContacts(where: { $0.name == "name1" }).first else {
        XCTFail("There is no contact with name name1")
        return
      }

      guard let man2 = book.listContacts(where: { $0.name == "name2" }).first else {
        XCTFail("There is no contact with name name2")
        return
      }

      try XCTAssertTrue(book.contacts(of: all).contains(man1))
      try XCTAssertTrue(book.contacts(of: all).contains(man2))
      try XCTAssertEqual(book.contacts(of: friends), [man1])

      try book.removeContact(man1)

      try XCTAssertEqual(book.contacts(of: all), [man2])
      try XCTAssertEqual(book.contacts(of: friends), [])
    }
  }

  func testChangeTitleOfGroup() throws {
    // GIVEN
    do {
      let book = try ContactBook()
      let man1 = try book.addContact(name: "name1", surname: "surname1", phone: "+1")
      let man2 = try book.addContact(name: "name2", surname: "surname2", phone: "+2")

      let friends = try book.addGroup(title: "Friendssss")
      let _ = try book.addGroup(title: "AllContactsss", contacts: [man1, man2])

      try book.add(to: friends, contact: man1)
    }

    // THEN
    do {
      let book = try ContactBook()
      XCTAssertEqual(book.groups.count, 2)

      guard let friends = book.groups.values.first(where: { $0.title == "Friendssss" }) else {
        XCTFail("No group with title Friendssss")
        return
      }

      guard let all = book.groups.values.first(where: { $0.title == "AllContactsss" }) else {
        XCTFail("No group with title AllContactsss")
        return
      }

      try book.changeTitle(of: friends, newTitle: "Friends")
      try book.changeTitle(of: all, newTitle: "AllContacts")

      guard let newFriends = book.groups[friends.id] else {
        XCTFail("There is no group with the given id")
        return
      }

      guard let newAll = book.groups[all.id] else {
        XCTFail("There is no group with the given id")
        return
      }

      XCTAssertEqual(newFriends.title, "Friends")
      XCTAssertEqual(newAll.title, "AllContacts")

    }
  }
}
