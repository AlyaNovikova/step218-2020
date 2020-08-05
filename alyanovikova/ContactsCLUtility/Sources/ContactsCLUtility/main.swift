import ArgumentParser
import Contacts
import Foundation

struct ContactsUtility: ParsableCommand {

  static let configuration = CommandConfiguration(
    abstract: "Contacts command line utility.",
    subcommands: [
      AllContacts.self,
      AddContact.self,
      UpdateContact.self,
      RemoveContact.self,
      AllGroups.self,
      AddGroup.self,
      AddContactToGroup.self,
      RemoveGroup.self,
      RemoveContactFromGroup.self,
      ChangeTitle.self,
    ])

  // Utility for contacts
  struct AllContacts: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Print all contacts")

    func run() throws {
      let book = try ContactBook()

      print("All contacts:")
      for contact in book.contacts.values {
        print(contact.id, ":", contact.name, contact.surname, contact.phone)
      }
    }
  }

  struct AddContact: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Add contact to ContactBook")

    @Argument(help: "Contact name")
    var name: String

    @Argument(help: "Contact surname")
    var surname: String

    @Argument(help: "Contact phone number")
    var phone: String

    func run() throws {
      let book = try ContactBook()

      let _ = try book.addContact(name: name, surname: surname, phone: phone)
    }
  }

  struct UpdateContact: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Update contact by id with new name/surname/phone")

    @Argument(help: "Id of contact you want to change")
    var id: String

    @Option(help: "New contact name")
    var name: String?

    @Option(help: "New contact surname")
    var surname: String?

    @Option(help: "new contact phone number")
    var phone: String?

    func validate() throws {
      guard let uuid = UUID(uuidString: id) else {
        throw ValidationError("Id does not match the UUID format")
      }

      let book = try ContactBook()
      guard let _ = book.contacts[uuid] else {
        throw ValidationError("Nonexistent id of contact")
      }
    }

    func run() throws {
      let book = try ContactBook()

      guard let uuid = UUID(uuidString: id) else {
        return
      }
      guard var contact = book.contacts[uuid] else {
        return
      }

      if let name = name {
        contact.name = name
      }
      if let surname = surname {
        contact.surname = surname
      }
      if let phone = phone {
        contact.phone = phone
      }
      book.contacts[uuid] = contact
    }
  }

  struct RemoveContact: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Remove contact by id")

    @Argument(help: "Id of contact you want to remove")
    var id: String

    func validate() throws {
      guard let uuid = UUID(uuidString: id) else {
        throw ValidationError("Id does not match the UUID format")
      }

      let book = try ContactBook()
      guard let _ = book.contacts[uuid] else {
        throw ValidationError("Nonexistent id of contact")
      }
    }

    func run() throws {
      let book = try ContactBook()

      guard let uuid = UUID(uuidString: id) else {
        return
      }

      try book.removeContact(id: uuid)
    }
  }

  // Utility for groups
  struct AllGroups: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Print all groups")

    func run() throws {
      let book = try ContactBook()

      print("All groups:")
      for group in book.groups.values {
        print(group.id, ":", group.title)
        print("Members:")
        for id in group.contactIds {
          if let contact = book.contacts[id] {
            print("\t", contact.name, contact.surname, contact.phone)
          }
        }
      }
    }
  }

  struct AddGroup: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Add group to ContactBook")

    @Argument(help: "Group title")
    var title: String

    func run() throws {
      let book = try ContactBook()

      let _ = try book.addGroup(title: title)
    }
  }

  struct AddContactToGroup: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Add contact to group")

    @Argument(help: "Id of group")
    var groupId: String

    @Argument(help: "Id of contact")
    var contactId: String

    func validate() throws {
      guard let groupUuid = UUID(uuidString: groupId) else {
        throw ValidationError("Group id does not match the UUID format")
      }
      guard let contactUuid = UUID(uuidString: contactId) else {
        throw ValidationError("Contact id does not match the UUID format")
      }

      let book = try ContactBook()

      guard let _ = book.groups[groupUuid] else {
        throw ValidationError("Nonexistent id of group")
      }
      guard let _ = book.contacts[contactUuid] else {
        throw ValidationError("Nonexistent id of contact")
      }
    }

    func run() throws {
      let book = try ContactBook()

      guard let groupUuid = UUID(uuidString: groupId) else {
        return
      }
      guard let contactUuid = UUID(uuidString: contactId) else {
        return
      }

      guard let group = book.groups[groupUuid] else {
        return
      }
      guard let contact = book.contacts[contactUuid] else {
        return
      }

      try book.add(to: group, contact: contact)
    }
  }

  struct RemoveGroup: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Remove group by id")

    @Argument(help: "Id of group you want to remove")
    var id: String

    func validate() throws {
      guard let uuid = UUID(uuidString: id) else {
        throw ValidationError("Id does not match the UUID format")
      }

      let book = try ContactBook()
      guard let _ = book.groups[uuid] else {
        throw ValidationError("Nonexistent id of group")
      }
    }

    func run() throws {
      let book = try ContactBook()

      guard let uuid = UUID(uuidString: id) else {
        return
      }

      try book.removeGroup(id: uuid)
    }
  }

  struct RemoveContactFromGroup: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Remove contact from group")

    @Argument(help: "Id of group")
    var groupId: String

    @Argument(help: "Id of contact")
    var contactId: String

    func validate() throws {
      guard let groupUuid = UUID(uuidString: groupId) else {
        throw ValidationError("Group id does not match the UUID format")
      }
      guard let contactUuid = UUID(uuidString: contactId) else {
        throw ValidationError("Contact id does not match the UUID format")
      }

      let book = try ContactBook()

      guard let _ = book.groups[groupUuid] else {
        throw ValidationError("Nonexistent id of group")
      }
      guard let _ = book.contacts[contactUuid] else {
        throw ValidationError("Nonexistent id of contact")
      }
    }

    func run() throws {
      let book = try ContactBook()

      guard let groupUuid = UUID(uuidString: groupId) else {
        return
      }
      guard let contactUuid = UUID(uuidString: contactId) else {
        return
      }

      guard let group = book.groups[groupUuid] else {
        return
      }
      guard let contact = book.contacts[contactUuid] else {
        return
      }

      try book.remove(from: group, contact: contact)
    }
  }

  struct ChangeTitle: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Change title of group by id")

    @Argument(help: "Id of group you want to change")
    var id: String

    @Argument(help: "New group title")
    var title: String

    func validate() throws {
      guard let uuid = UUID(uuidString: id) else {
        throw ValidationError("Id does not match the UUID format")
      }

      let book = try ContactBook()
      guard let _ = book.groups[uuid] else {
        throw ValidationError("Nonexistent id of group")
      }
    }

    func run() throws {
      let book = try ContactBook()

      guard let uuid = UUID(uuidString: id) else {
        return
      }
      guard let group = book.groups[uuid] else {
        return
      }

      try book.changeTitle(of: group, newTitle: title)
    }
  }

}

ContactsUtility.main()
