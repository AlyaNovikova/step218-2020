func array() {
  //  Array examples, the type can be derived from the context, but can be specified explicitly.
  let numbers = [1, 2, 3]
  var arrayOfDomains: [String] = ["apple.com", "google.com"]

  //  For this array we have to specify the type as it can not be evaluated from the context.
  let arrayOfDifferentThings: [Any] = [1, 2, ""]

  //  To add something we can do:
  arrayOfDomains.append("microsoft.com")

  //  To get value at index:
  let appleDomain = arrayOfDomains[1]

  //  It is going tocrash when index is out of range:
  //let domainForNotExisingIndex = arrayOfDomains[3]

  //  Convenience method to get first element:
  let firstDomain = arrayOfDomains.first

  //  And last one:
  let lastDomain = arrayOfDomains.last

  //  To enumerate through the array
  for domain in arrayOfDomains {
    print(domain)
  }

  //  To get array size(number of elements)
  let size = arrayOfDomains.count

  //  To remove element at index, crashes when out of range:
  let element = arrayOfDomains.remove(at: 1)

  //  to insert at index, crashes when out of range:
  arrayOfDomains.insert("facebook.com", at: 2)

  //  to replace at index:
  arrayOfDomains[1] = "facebook.com"
}


//  MARK: Do it yourself
struct Student {
  typealias Group = Int
  let name: String
  let age: Int
  let group: Group
}

class Classroom {
  private var students: [Student] = []

  func add(student: Student) {
    students.append(student)
  }

  func student(with name: String) -> Student? {
    return students.first(where: { $0.name == name })
  }

  func students(of group: Student.Group) -> [Student] {
    var groupOfStudents: [Student] = []
    for student in students {
      if (student.group == group) {
        groupOfStudents.append(student)
      }
    }
    return groupOfStudents
  }
}

let alya = Student(name: "alya", age: 20, group: 0)
let ira = Student(name: "ira", age: 20, group: 1)
let yulia = Student(name: "yulia", age: 20, group: 1)

var cRoom = Classroom()
cRoom.add(student: alya)
cRoom.add(student: ira)
assert(cRoom.students(of: 0).count == 1)
cRoom.add(student: yulia)
assert(cRoom.students(of: 1).count == 2)
if let alya = cRoom.student(with: "alya") {
  print(alya)
}
