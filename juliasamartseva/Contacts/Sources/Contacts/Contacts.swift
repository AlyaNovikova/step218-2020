import Foundation
import Logging

// MARK: - Contact class

public struct Contact: Codable, Equatable {

  public let id: UUID
  public var name: String
  public var phone: String
  public var email: String?
  public var work: WorkInfo?

  public init(name: String, phone: String, email: String?, work: WorkInfo?) throws {

    /// The name and phone must not be empty.
    guard !name.isEmpty else {
      throw ContactError.emptyName
    }
    guard !phone.isEmpty else {
      throw ContactError.emptyPhone
    }

    /// Phone and email (if exists) must be of the valid format
    guard phone.isValidPhone else {
      throw ContactError.invalidPhone
    }
    if let email = email {
      guard email.isValidEmail else {
        throw ContactError.invalidEmail
      }
    }

    self.name = name
    self.phone = phone
    self.email = email
    self.work = work
    self.id = UUID()
    
  }
}

enum ContactError: Error {
  case emptyName
  case emptyPhone
  case invalidEmail
  case invalidPhone
}

public struct WorkInfo: Codable, Equatable {
  public var jobTitle: String
  public var company: String?
}

// MARK: - ContactList class

public class ContactList {
  private let fileURL: URL
  public internal(set) var contacts = [Contact]()
  public var size: Int {
    return contacts.count
  }
  private let logger = Logger(label: "com.google.Contacts.ContactList")

  public init() throws {
    logger.info("Creating contact from file")
    fileURL = try Self.makeDefaultURL()
    do {
      contacts = try [Contact](jsonFileURL: fileURL)
    } catch CocoaError.fileReadNoSuchFile {
      contacts = []
      logger.error("Successfully initialized empty list")
    } catch let error {
      logger.error("Failed to initialize the contacts with: \(error)")
      throw error
    }
  }

  // MARK: - API

  public func add(_ contact: Contact) throws {
    contacts.append(contact)
    try writeToFile()
    logger.info("Successfully added contact with id \(contact.id) to contact list")
  }

  public func contacts(where predicate: (Contact) -> Bool) -> [Contact] {
    logger.info("Searching contact by predicate")
    var result = [Contact]()
    for contact in contacts {
      if predicate(contact) { result.append(contact) }
    }
    return result
  }

  public func contact(withId id: UUID) -> Contact? {
    logger.info("Searching contact with id \(id)")
    return contacts.first(where: { $0.id == id })
  }

  public func update(contact: Contact) throws {
    if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
      contacts[index] = contact
      try writeToFile()
      logger.info("Successfully changed contact with id \(contact.id) to new contact")
    } else {
      logger.info("No contact with \(contact.id) was found")
    }
  }

  public func remove(_ contact: Contact) throws {
    contacts.removeAll(where: { $0 == contact })
    try writeToFile()
    logger.info("Successfully removed contact with id \(contact.id)")
  }

  static func makeDefaultURL() throws -> URL {
    let documentsDirectory = try FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true)
    return documentsDirectory.appendingPathComponent("tasks")
  }

  private func writeToFile() throws {
    do {
      try contacts.writeJSON(to: fileURL)
    } catch let error {
      logger.error("Unable to write JSON for contacts")
      throw error
    }
  }
}

// MARK: - Validation functions

extension String {
  var isValidPhone: Bool {
    return range(of: "\\A[0-9]{12}\\z", options: .regularExpression) != nil
  }
  var isValidEmail: Bool {
    return range(of: ".+@.+\\..", options: .regularExpression) != nil
  }
}

// MARK: - Writing and reading data from file

extension Encodable {
  func writeJSON(to fileURL: URL) throws {
    let data = try JSONEncoder().encode(self)
    try data.write(to: fileURL)
  }
}

extension Decodable {
  init(jsonFileURL: URL) throws {
    let data = try Data(contentsOf: jsonFileURL)
    self = try JSONDecoder().decode(Self.self, from: data)
  }
}
