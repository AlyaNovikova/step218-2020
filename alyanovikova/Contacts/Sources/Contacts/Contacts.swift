import Foundation
import Logging

public struct Contact: Codable {
  public typealias Id = Int

  public let id: Id
  public var name: String
  public var surname: String
  public var phone: String

  public init(id: Id, name: String, surname: String, phone: String) {
    self.id = id
    self.name = name
    self.surname = surname
    self.phone = phone
  }
}

struct ContactList: Codable {
  let contacts: [Contact.Id: Contact]
  let lastId: Contact.Id

  init(contacts: [Contact.Id: Contact], lastId: Contact.Id) {
    self.contacts = contacts
    self.lastId = lastId
  }
}

public class ContactBook {
  public var contacts = [Contact.Id: Contact]()
  private var lastId: Contact.Id = 0
  private let fileURL: URL
  private let logger = Logger(label: "com.google.WearOS.ContactBook")

  enum ContactError: Error {
    case nonexistentId
  }

  public init() throws {
    fileURL = try Self.makeDefaultURL()
    do {
      let contactList = try ContactList(jsonFileURL: fileURL)
      contacts = contactList.contacts
      lastId = contactList.lastId
    } catch CocoaError.fileReadNoSuchFile {
      contacts = [:]
      lastId = 0
      logger.error("FileURL not found, init with blank ContactBook")
    } catch let error {
      logger.error("Failed to init ContactBook with \(error)")
    }
  }

  init(contacts: [Contact.Id: Contact], lastId: Contact.Id) throws {
    fileURL = try Self.makeDefaultURL()
    self.contacts = contacts
    self.lastId = lastId
  }

  public func addContact(name: String, surname: String, phone: String) throws -> Contact {
    lastId += 1
    let newId = lastId
    let newContact = Contact(id: newId, name: name, surname: surname, phone: phone)
    contacts[newId] = newContact

    do {
      try ContactList(contacts: contacts, lastId: lastId).writeJSON(to: fileURL)
    } catch let error {
      logger.error("Failed to write to file in function addContact with \(error)")
    }

    return newContact
  }

  public func updateContact(newContact: Contact) throws {
    guard let _ = contacts[newContact.id] else {
      logger.error("Failed to update contact by nonexistent id \(newContact.id)")
      throw ContactError.nonexistentId
    }
    contacts[newContact.id] = newContact

    do {
      try ContactList(contacts: contacts, lastId: lastId).writeJSON(to: fileURL)
    } catch let error {
      logger.error("Failed to write to file in function updateContact with \(error)")
    }
  }

  public func removeContact(id: Contact.Id) throws {
    contacts.removeValue(forKey: id)

    do {
      try ContactList(contacts: contacts, lastId: lastId).writeJSON(to: fileURL)
    } catch let error {
      logger.error("Failed to write to file in function removeContact with \(error)")
    }
  }

  public func listContacts(where predicate: (Contact) -> Bool) -> [Contact] {
    return contacts.values.filter { predicate($0) }
  }

  static func makeDefaultURL() throws -> URL {
    //    do {
    let documentsDirectory = try FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true)
    return documentsDirectory.appendingPathComponent("ContactBook")
    //    } catch let error {
    //      logger.error("Failed to make default URL with \(error)")
    //    }
  }
}

extension Encodable {
  fileprivate func writeJSON(to fileURL: URL) throws {
    let data = try JSONEncoder().encode(self)
    try data.write(to: fileURL)
  }
}

extension Decodable {
  fileprivate init(jsonFileURL: URL) throws {
    let data = try Data(contentsOf: jsonFileURL)
    self = try JSONDecoder().decode(Self.self, from: data)
  }
}
