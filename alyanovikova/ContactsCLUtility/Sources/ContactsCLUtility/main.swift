import Foundation
import ArgumentParser
import Contacts

struct ContactsUtility: ParsableCommand {

  static let configuration = CommandConfiguration(
    abstract: "Contacts command line utility.",
    subcommands: [AllContacts.self,
                  AddContact.self,
                  UpdateContact.self,
                  RemoveContact.self])

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

    @Option(help: "Contact name")
    var name: String?

    @Option(help: "Contact surname")
    var surname: String?

    @Option(help: "Contact phone number")
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
      abstract: "Update contact by id with new name/surname/phone")

    @Argument(help: "Id of contact you want to change")
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
}

ContactsUtility.main()
