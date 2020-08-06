import Foundation
import Logging

public struct Contact: Equatable, Codable {
  public typealias Id = UUID

  public let id: Id
  public var name: String
  public var surname: String
  public var phone: String

  public init(name: String, surname: String, phone: String) {
    id = Id()

    self.name = name
    self.surname = surname
    self.phone = phone
  }
}

public struct Group: Codable {
  public typealias Id = UUID

  public let id: Id
  public internal(set) var title: String
  public internal(set) var contactIds: Set<Contact.Id>

  public init(title: String, contactIds: Set<Contact.Id> = []) {
    id = Id()

    self.title = title
    self.contactIds = contactIds
  }

  mutating func add(contactId: Contact.Id) {
    if !contactIds.contains(contactId) {
      contactIds.insert(contactId)
    }
  }

  mutating func remove(contactId: Contact.Id) {
    if let index = contactIds.firstIndex(of: contactId) {
      contactIds.remove(at: index)
    }
  }
}

// Struct to write to file
struct GroupsAndContacts: Codable {
  let contacts: [Contact.Id: Contact]
  let groups: [Group.Id: Group]

  init(contacts: [Contact.Id: Contact], groups: [Group.Id: Group] = [:]) {
    self.contacts = contacts
    self.groups = groups
  }
}

public class ContactBook {
  public internal(set) var contacts = [Contact.Id: Contact]()
  public internal(set) var groups = [Group.Id: Group]()

  private let fileURL: URL
  private let logger = Logger(label: "com.google.Internship.ContactBook")

  enum ContactError: Error {
    case nonexistentIdOfContact
    case nonexistentIdOfGroup
  }

  public init() throws {
    fileURL = try Self.makeDefaultURL()

    do {
      let groupsAndContacts = try GroupsAndContacts(jsonFileURL: fileURL)
      contacts = groupsAndContacts.contacts
      groups = groupsAndContacts.groups
    } catch CocoaError.fileReadNoSuchFile {
      contacts = [:]
      groups = [:]
      logger.error("FileURL not found, init with blank ContactBook")
    } catch {
      logger.error("Failed to init ContactBook with \(error)")
    }
  }

  // Functions with Contact
  public func addContact(name: String, surname: String, phone: String) throws -> Contact {
    let newContact = Contact(name: name, surname: surname, phone: phone)
    contacts[newContact.id] = newContact

    try writeToFile()

    return newContact
  }

  public func updateContact(newContact: Contact) throws {
    guard let _ = contacts[newContact.id] else {
      logger.error("Failed to update contact by nonexistent id \(newContact.id)")
      throw ContactError.nonexistentIdOfContact
    }
    contacts[newContact.id] = newContact

    try writeToFile()
  }

  public func removeContact(_ contact: Contact) throws {
    contacts.removeValue(forKey: contact.id)

    try writeToFile()
  }

  public func listContacts(where predicate: (Contact) -> Bool) -> [Contact] {
    return contacts.values.filter { predicate($0) }
  }

  // Functions with Group
  public func addGroup(title: String, contacts: [Contact] = []) throws -> Group {
    let newGroup = Group(title: title, contactIds: Set(contacts.map({ $0.id })))
    groups[newGroup.id] = newGroup

    try writeToFile()

    return newGroup
  }

  public func add(to group: Group, contact: Contact) throws {
    guard var existGroup = groups[group.id] else {
      logger.error("Failed to add contact to group due to a nonexistent group id \(group.id)")
      throw ContactError.nonexistentIdOfGroup
    }

    guard let _ = contacts[contact.id] else {
      logger.error("Failed to add contact to group due to a nonexistent contact id \(contact.id)")
      throw ContactError.nonexistentIdOfContact
    }

    existGroup.add(contactId: contact.id)
    groups[group.id] = existGroup

    try writeToFile()
  }

  public func removeGroup(_ group: Group) throws {
    groups.removeValue(forKey: group.id)

    try writeToFile()
  }

  public func remove(from group: Group, contact: Contact) throws {
    guard var existGroup = groups[group.id] else {
      logger.error("Failed to remove contact from group due to a nonexistent group id \(group.id)")
      throw ContactError.nonexistentIdOfGroup
    }

    guard let _ = contacts[contact.id] else {
      logger.error(
        "Failed to remove contact grom group due to a nonexistent contact id \(contact.id)")
      throw ContactError.nonexistentIdOfContact
    }

    existGroup.remove(contactId: contact.id)
    groups[group.id] = existGroup

    try writeToFile()
  }

  public func contacts(of group: Group) throws -> [Contact] {
    guard var existGroup = groups[group.id] else {
      logger.error("Failed to get group members due to nonexistent group id \(group.id)")
      throw ContactError.nonexistentIdOfGroup
    }

    var contactsList: [Contact] = []
    for id in existGroup.contactIds {
      if let contact = contacts[id] {
        contactsList.append(contact)
      } else {
        existGroup.remove(contactId: id)
      }
    }

    groups[group.id] = existGroup
    try writeToFile()

    return contactsList
  }

  public func changeTitle(of group: Group, newTitle: String) throws {
    guard var existGroup = groups[group.id] else {
      logger.error("Failed to add contact to group due to a nonexistent group id \(group.id)")
      throw ContactError.nonexistentIdOfGroup
    }

    existGroup.title = newTitle
    groups[group.id] = existGroup

    try writeToFile()
  }

  // Functions for working with files
  static func makeDefaultURL() throws -> URL {
    let documentsDirectory = try FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true)
    return documentsDirectory.appendingPathComponent("ContactBook")
  }

  func writeToFile() throws {
    do {
      let groupsAndContacts = GroupsAndContacts(contacts: contacts, groups: groups)
      try groupsAndContacts.writeJSON(to: fileURL)
    } catch {
      logger.error("Failed to write to file with \(error)")
    }
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
