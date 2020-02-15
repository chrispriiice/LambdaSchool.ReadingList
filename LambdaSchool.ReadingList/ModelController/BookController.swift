
import Foundation

class BookController {
    
    init() {
        loadFromPersistentStore()
    }
    
    // Mark: - Properties
    
    var books: [Book] = []
    
    var readingListURL: URL? {
        let fileManager = FileManager.default
        guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {return nil}
        return documents.appendingPathComponent("books.plist")
    }
    
    // Mark: - CRUD
    
    @discardableResult func createBook(title: String, reasonToRead: String, hasBeenRead: Bool) -> Book {
        let book = Book(title: title, reasonToRead: reasonToRead, hasBeenRead: hasBeenRead)
        books.append(book)
        saveToPersistentStore()
        return book
    }
    
    func toggleHasBeenRead(book: Book) {
        guard let index = books.firstIndex(of: book) else { return }
        books[index].hasBeenRead.toggle()
        saveToPersistentStore()
    }
    
    func editBook(book: Book) {
        guard let index = books.firstIndex(of: book) else { return }
        books[index].title = book.title
        books[index].reasonToRead = book.reasonToRead
        saveToPersistentStore()
    }
    
    func removeBook(book: Book) {
        books = books.filter { $0 != book }
        saveToPersistentStore()
    }
    // Source: https://stackoverflow.com/questions/40859066/removing-object-from-array-in-swift-3/40860256
    
    // Mark: - Save and Load
    
    func saveToPersistentStore() {
        guard let url = readingListURL else {return}
        
        do {
            let encoder = PropertyListEncoder()
            let booksData = try encoder.encode(books)
            try booksData.write(to: url)
        } catch {
            print("Error saving books data: \(error)")
        }
    }
    
    func loadFromPersistentStore() {
        let fileManager = FileManager.default
        guard let url = readingListURL,
            fileManager.fileExists(atPath: url.path) else {return}
        
        do {
            let booksData = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            books = try decoder.decode([Book].self, from: booksData)
        } catch {
            print("Error loading books data: \(error)")
        }
    }
}
