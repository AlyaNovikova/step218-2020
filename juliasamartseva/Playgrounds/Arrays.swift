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

  func student(named name: String) -> Student? {
    return students.first(where: { $0.name == name })
  }

  func students(ofGroup group: Student.Group) -> [Student] {
    var result = [Student]()
    for student in students {
      if student.group == group { result.append(student) }
    }
    return result
  }
}

let classroom = Classroom()
classroom.add(student: Student(name: "Tanya", age: 12, group: 1))
classroom.add(student: Student(name: "Darra", age: 12, group: 2))
classroom.add(student: Student(name: "Tonya", age: 12, group: 1))
classroom.add(student: Student(name: "Alla", age: 12, group: 1))

if let student = classroom.student(named: "Alla") {
  print("Alla is ", student.age, " years old")
}

if let student = classroom.student(named: "Comfd") {
  print("Alla is ", student.age, " years old")
} else {
  print("There is no one with such name")
}

let groupOne = classroom.students(ofGroup: 1)
for student in groupOne {
  print("Student ", student.name)
}
