struct Contact {
  typealias Id = Int

  let id: Id
  var name: String
  var surname: String
  var phone: String

  init(id: Id, name: String, surname: String, phone: String) {
    self.id = id
    self.name = name
    self.surname = surname
    self.phone = phone
  }
}

class ContactBook {
  public var contacts = [Contact.Id: Contact]()
  private var counter: Contact.Id = 0

  func addContact(name: String, surname: String, phone: String) -> Contact {
    counter += 1
    let newId = counter
    let newContact = Contact(id: newId, name: name, surname: surname, phone: phone)
    contacts[newId] = newContact
    return newContact
  }
  
  func updateContact(id: Contact.Id, name: String? = nil, surname: String? = nil, phone: String? = nil) -> Bool {
    guard var contact = contacts[id] else {
      return false
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
    contacts[id] = contact
    return true
  }

  func updateContact(id: Contact.Id, newContact: Contact) -> Bool {
    guard let _ = contacts[id] else {
      return false
    }
    contacts[id] = newContact
    return true
  }

  func removeContact(id: Contact.Id) {
    contacts.removeValue(forKey: id)
  }

  func listContacts(where predicate: (Contact) -> Bool) -> [Contact] {
    return contacts.values.filter( {predicate($0)} )
  }
}

enum ContactError: Error {
  case noContact
}

var book = ContactBook()
let alya = book.addContact(name: "Alya", surname: "Nov", phone: "+7911")
let julia = book.addContact(name: "Juliaaaaa", surname: "Sam", phone: "+3800")
let ira = book.addContact(name: "Nil", surname: "Nil", phone: "Nil")
let correctIra = Contact(id: ira.id, name: "Ira", surname: "Hor", phone: "+3801")

guard let contactAlya = book.contacts[alya.id] else {
  throw ContactError.noContact
}
assert(contactAlya.name == "Alya")

book.updateContact(id: julia.id, name: "Julia")
guard let contactJulia = book.contacts[julia.id] else {
  throw ContactError.noContact
}
assert(contactJulia.name == "Julia")

book.updateContact(id: ira.id, newContact: correctIra)
guard let contactIra = book.contacts[ira.id] else {
  throw ContactError.noContact
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
