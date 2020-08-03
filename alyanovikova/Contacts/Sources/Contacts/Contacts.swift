import Foundation
import Logging

public struct Contact: Codable {
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

public class ContactBook {
  public var contacts = [Contact.Id: Contact]()
  private let fileURL: URL
  private let logger = Logger(label: "com.google.WearOS.ContactBook")

  enum ContactError: Error {
    case nonexistentId
    case noContact
  }

  public init() throws {
    fileURL = try Self.makeDefaultURL()
    do {
      contacts = try [Contact.Id: Contact](jsonFileURL: fileURL)
    } catch CocoaError.fileReadNoSuchFile {
      contacts = [:]
      logger.error("FileURL not found, init with blank ContactBook")
    } catch let error {
      logger.error("Failed to init ContactBook with \(error)")
    }
  }

  public func addContact(name: String, surname: String, phone: String) throws -> Contact {
    let newContact = Contact(name: name, surname: surname, phone: phone)
    contacts[newContact.id] = newContact

    do {
      try contacts.writeJSON(to: fileURL)
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
      try contacts.writeJSON(to: fileURL)
    } catch let error {
      logger.error("Failed to write to file in function updateContact with \(error)")
    }
  }

  public func removeContact(id: Contact.Id) throws {
    contacts.removeValue(forKey: id)

    do {
      try contacts.writeJSON(to: fileURL)
    } catch let error {
      logger.error("Failed to write to file in function removeContact with \(error)")
    }
  }

  public func listContacts(where predicate: (Contact) -> Bool) -> [Contact] {
    return contacts.values.filter { predicate($0) }
  }

  static func makeDefaultURL() throws -> URL {
    let documentsDirectory = try FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true)
    return documentsDirectory.appendingPathComponent("ContactBook")
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
