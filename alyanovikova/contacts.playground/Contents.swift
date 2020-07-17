typealias Id = Int

class Contact {
  var name: String
  var  surname: String
  var phone: String

  init(name: String, surname: String, phone: String) {
    self.name = name
    self.surname = surname
    self.phone = phone
  }
}

class Contacts {
  var contacts = [Id: Contact]()
  var counter: Id = 0

  func createNewContact(name: String, surname: String, phone: String) -> Id {
    counter += 1
    let newId = counter
    let newContact = Contact(name: name, surname: surname, phone: phone)
    contacts[newId] = newContact
    return newId
  }

  func updateContact(id: Id, name: String? = nil, surname: String? = nil, phone: String? = nil) -> Void {
    guard let contact = contacts[id] else {
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
  }

  func updateContact(id: Id, newContact: Contact) -> Void {
    if let _ = contacts[id] {
      contacts[id] = newContact
    }
  }

  func removeContact(id: Id) -> Void {
    contacts.removeValue(forKey: id)
  }

  func listContacts(where predicate: (Contact) -> Bool) -> [Id] {
    var listContacts: [Id] = []
    for (id, contact) in contacts {
      if predicate(contact) {
        listContacts.append(id)
      }
    }
    return listContacts
  }
}

enum ContactError: Error {
  case NoContact
}

var book = Contacts()
let alya = book.createNewContact(name: "Alya", surname: "Nov", phone: "+7911")
let julia = book.createNewContact(name: "Juliaaaaa", surname: "Sam", phone: "+3800")
let ira = book.createNewContact(name: "Nil", surname: "Nil", phone: "Nil")
let correctIra = Contact(name: "Ira", surname: "Hor", phone: "+3801")

guard let contactAlya = book.contacts[alya] else {
  throw ContactError.NoContact
}
assert(contactAlya.name == "Alya")

book.updateContact(id: julia, name: "Julia")
guard let contactJulia = book.contacts[julia] else {
  throw ContactError.NoContact
}
assert(contactJulia.name == "Julia")

book.updateContact(id: ira, newContact: correctIra)
guard let contactIra = book.contacts[ira] else {
  throw ContactError.NoContact
}
assert(contactIra.name == "Ira")

assert(book.listContacts(where: {
  guard $0.phone.count > 0 else {
    return false
  }
  return $0.phone[$0.phone.startIndex] == "+"
}).count == 3)

book.removeContact(id: alya)
assert(book.contacts[alya] == nil)
assert(book.listContacts(where: {
  guard $0.phone.count > 0 else {
    return false
  }
  return $0.phone[$0.phone.startIndex] == "+"
}).count == 2)
