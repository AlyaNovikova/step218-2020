class Bookmark {
  weak var book: Book?

  var note: String
  let page: Int
  let position: Int

  init(note: String, page: Int, position: Int) {
    self.note = note
    self.page = page
    self.position = position
  }
}

extension Bookmark: Equatable {
  static func == (lhs: Bookmark, rhs: Bookmark) -> Bool {
    return lhs.note == rhs.note &&
      lhs.page == rhs.page &&
      lhs.position == rhs.position &&
      lhs.book === rhs.book
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

  func add(bookmark: Bookmark) {
    bookmarks.append(bookmark)
    bookmark.book = self
  }
  
  func delete(bookmark: Bookmark) {
    if let index = bookmarks.firstIndex(of: bookmark) {
      bookmarks.remove(at: index)
    }
  }
}

let myBook = Book(title: "The Lord of the rings", pages: ["once upon a time", "aaaaaAaaa", "the end."])
let myBm1 = Bookmark(note: "so exciting", page: 0, position: 1)
let myBm2 = Bookmark(note: "I'm in shock", page: 1, position: 4)

myBook.add(bookmark: myBm1)
myBook.add(bookmark: myBm2)

print("Number of bookmarks in \"The Lord of the rings\" is", myBook.bookmarks.count)
if let book = myBm1.book {
  print(book.title, ":")
}
if let book = myBm2.book {
  print(book.pages)
}
