//MARK: - Books
class Book {
  let name: String
  let pageNumber: Int
  let content: String
  let author: String
  private var bookmarks = [Bookmark]()

  init(name: String, pages pageNumber: Int, content: String, author: String) {
    self.name = name
    self.pageNumber = pageNumber
    self.content = content
    self.author = author
  }

  func addBookmark(_ bookmark: Bookmark) {
    if bookmark.page < 0 || bookmark.page > pageNumber {
      print("Bookmark cannot be added. Number of pages is not applicable")
    } else {
      bookmarks.append(bookmark)
    }
  }

  func removeBookmark(_ bookmark: Bookmark) {
    if !bookmarks.contains(bookmark) {
      print("No such bookmark")
    } else if let index = bookmarks.firstIndex(of: bookmark) {
      bookmarks.remove(at: index)
    }
  }

  func read(from bookmark: Bookmark) {
    if !bookmarks.contains(bookmark) {
      print("No such bookmark")
    } else if let name = bookmark.book?.name {
      print("Reading \(name) starting from \(bookmark.page) page")
    }
  }
}

struct Bookmark {
  weak var book: Book?
  /// Page on which the bookmark is located.
  let page: Int

  init(book: Book, page: Int) {
    self.book = book
    self.page = page
    book.addBookmark(self)
  }

  init(page: Int) {
    self.book = nil
    self.page = page
  }

  mutating func changeBook(to newBook: Book) {
    if let book = book {
      book.removeBookmark(self)
    }
    book = newBook
    newBook.addBookmark(self)
  }
}

extension Bookmark: Equatable {
  static func == (lhs: Bookmark, rhs: Bookmark) -> Bool {
    return
      lhs.page == rhs.page && lhs.book === rhs.book
  }
}

//MARK: - Testing the code

let book1 = Book(name: "First book", pages: 100, content: "Book1 content", author: "Steve")
let book2 = Book(name: "Second book", pages: 100, content: "Book2 content", author: "Mark")
var bookmark1 = Bookmark(book: book1, page: 10)
var bookmark2 = Bookmark(book: book1, page: 30)
var bookmark3 = Bookmark(page: 50)
bookmark2.changeBook(to: book2)
bookmark3.changeBook(to: book2)

assert(bookmark1.book!.name == "First book")
assert(bookmark2.book!.name == "Second book")
assert(bookmark3.book!.name == "Second book")

book1.read(from: bookmark1)
book2.read(from: bookmark1)
book2.read(from: bookmark2)
book2.read(from: bookmark3)
