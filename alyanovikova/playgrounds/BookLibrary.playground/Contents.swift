class Bookmark {
  weak var book: Book?

  var note: String
  let pageNumber: Int
  let position: Int

  init(note: String, pageNumber: Int, position: Int) {
    self.note = note
    self.pageNumber = pageNumber
    self.position = position
  }
}

extension Bookmark: Equatable {
  static func == (lhs: Bookmark, rhs: Bookmark) -> Bool {
    return (lhs.note == rhs.note && lhs.pageNumber == rhs.pageNumber && lhs.position == rhs.position)
  }
}

class Book {
  let title: String
  let pages: [String]

  var bookmarks = [Bookmark]()

  init(title: String, pages: [String]) {
    self.title = title
    self.pages = pages
  }

  func addBookmark(bookmark: Bookmark) {
    bookmarks.append(bookmark)
    bookmark.book = self
  }
  
  func deleteBookmar(bookmark: Bookmark) {
    if let index = bookmarks.firstIndex(of: bookmark) {
      bookmarks.remove(at: index)
    }
  }
}

let myBook = Book(title: "The Lord of the rings", pages: ["once upon a time", "aaaaaAaaa", "the end."])
let myBm1 = Bookmark(note: "so exciting", pageNumber: 0, position: 1)
let myBm2 = Bookmark(note: "I'm in shock", pageNumber: 1, position: 4)

myBook.addBookmark(bookmark: myBm1)
myBook.addBookmark(bookmark: myBm2)

print("Number of bookmarks in \"The Lord of the rings\" is", myBook.bookmarks.count)
if let book = myBm1.book {
  print(book.title, ":")
}
if let book = myBm2.book {
  print(book.pages)
}
