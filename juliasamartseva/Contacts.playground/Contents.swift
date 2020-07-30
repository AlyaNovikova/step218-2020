import Foundation

// MARK: - Contact class

public struct Contact: Codable, Equatable {

  public let id = UUID()
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

  public internal(set) var contacts = [Contact]()
  var size: Int {
    return contacts.count
  }

  init(contacts: Contact...) {
    self.contacts = contacts
  }

  init(contacts: [Contact]) {
    self.contacts = contacts
  }

  // MARK: - API

  public func add(_ contact: Contact) {
    contacts.append(contact)
  }

  public func contacts(where predicate: (Contact) -> Bool) -> [Contact] {
    var result = [Contact]()
    for contact in contacts {
      if predicate(contact) { result.append(contact) }
    }
    return result
  }

  public func contact(withId id: UUID) -> Contact? {
    return contacts.first(where: { $0.id == id })
  }

  public func changeContact(by id: UUID, to newContact: Contact) {
    if let index = contacts.firstIndex(where: { $0.id == id }) {
      contacts[index].name = newContact.name
      contacts[index].phone = newContact.phone
      contacts[index].email = newContact.email
      contacts[index].work = newContact.work
    }
  }

  public func remove(_ contact: Contact) {
    contacts.removeAll(where: { $0 == contact })
  }
}

// MARK: - Validation functions

extension String {
  private static let phoneRegex = "\\A[0-9]{12}\\z"
  private static let emailRegex = ".+@.+\\.."

  var isValidPhone: Bool {
    return self.range(of: String.phoneRegex, options: .regularExpression) != nil
  }
  var isValidEmail: Bool {
    return self.range(of: String.emailRegex, options: .regularExpression) != nil
  }
}

// MARK: - Testing
enum TestingError: Error {
  case invalidVariable
}
/// Creating a new contact.
guard
  let sergii = try? Contact(name: "Sergii", phone: "380660989878", email: "df@g.com", work: nil),
  let lisa = try? Contact(
    name: "Lisa", phone: "380670989008", email: nil,
    work: WorkInfo(jobTitle: "Manager", company: nil)),
  let emma = try? Contact(
    name: "Emma", phone: "380470444403", email: "hello@gmail.com",
    work: WorkInfo(jobTitle: "Translator", company: nil))
else {
  throw TestingError.invalidVariable
}
let id = sergii.id
var contacts = ContactList(contacts: sergii, lisa)
contacts.add(emma)

/// Updating contact by id.
guard
  let newContact = try? Contact(name: "Sergey", phone: "380660989878", email: "df@g.com", work: nil)
else {
  throw TestingError.invalidVariable
}
contacts.changeContact(by: id, to: newContact)
let changedContact = contacts.contact(withId: id)
assert(changedContact!.name == "Sergey")

/// List contacts matching query.
let emmas = contacts.contacts { $0.name == "Emma" }
assert(emmas[0] == emma)

/// Remove contact.
contacts.remove(lisa)
assert(contacts.size == 2)

/// Get size of the list.
let list = ContactList()
list.add(sergii)
assert(list.size == 1)
list.add(lisa)
assert(list.size == 2)
