import Foundation

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

public class ContactBook: Codable {
  public var contacts = [Contact.Id: Contact]()
  private var lastId: Contact.Id = 0
  private let fileURL: URL

  enum ContactError: Error {
    case noContact
  }

  public init() throws {
    fileURL = try Self.makeDefaultURL()
    do {
      let contactBook = try ContactBook(jsonFileURL: fileURL)
      contacts = contactBook.contacts
      lastId = contactBook.lastId
    } catch CocoaError.fileReadNoSuchFile {
      contacts = [:]
      lastId = 0
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

    try self.writeJSON(to: fileURL)

    return newContact
  }

  public func updateContact(newContact: Contact) throws {
    guard let _ = contacts[newContact.id] else {
      throw ContactError.noContact
    }
    contacts[newContact.id] = newContact

    try self.writeJSON(to: fileURL)
  }

  public func removeContact(id: Contact.Id) throws {
    contacts.removeValue(forKey: id)

    try self.writeJSON(to: fileURL)
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
