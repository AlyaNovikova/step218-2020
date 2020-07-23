public struct Contact {
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

public class ContactBook {
  public var contacts = [Contact.Id: Contact]()
  private var lastId: Contact.Id = 0

  enum ContactError: Error {
    case noContact
  }

  public func addContact(name: String, surname: String, phone: String) -> Contact {
    lastId += 1
    let newId = lastId
    let newContact = Contact(id: newId, name: name, surname: surname, phone: phone)
    contacts[newId] = newContact
    return newContact
  }

  public func updateContact(id: Contact.Id, newContact: Contact) throws {
    guard let _ = contacts[id] else {
      throw ContactError.noContact
    }
    contacts[id] = newContact
  }

  public func removeContact(id: Contact.Id) {
    contacts.removeValue(forKey: id)
  }

  public func listContacts(where predicate: (Contact) -> Bool) -> [Contact] {
    return contacts.values.filter {predicate($0)}
  }
}

var book = ContactBook()
let alya = book.addContact(name: "Alya", surname: "Nov", phone: "+7911")
let julia = book.addContact(name: "Juliaaaaa", surname: "Sam", phone: "+3800")
let ira = book.addContact(name: "Nil", surname: "Nil", phone: "Nil")
let correctIra = Contact(id: ira.id, name: "Ira", surname: "Hor", phone: "+3801")

guard let contactAlya = book.contacts[alya.id] else {
  throw ContactBook.ContactError.noContact
}
assert(contactAlya.name == "Alya")

try book.updateContact(id: julia.id, newContact: Contact(id: julia.id, name: "Julia", surname: julia.surname, phone: julia.phone))
guard let contactJulia = book.contacts[julia.id] else {
  throw ContactBook.ContactError.noContact
}
assert(contactJulia.name == "Julia")

try book.updateContact(id: ira.id, newContact: correctIra)
guard let contactIra = book.contacts[ira.id] else {
  throw ContactBook.ContactError.noContact
}
assert(contactIra.name == "Ira")

assert(book.listContacts(where: {
  guard $0.phone.count > 0 else {
    return false
  }
  return $0.phone[$0.phone.startIndex] == "+"
}).count == 3)

book.removeContact(id: alya.id)
assert(book.contacts[alya.id] == nil)
assert(book.listContacts(where: {
  guard $0.phone.count > 0 else {
    return false
  }
  return $0.phone[$0.phone.startIndex] == "+"
}).count == 2)
