import Foundation

struct WordCollection: Codable, Identifiable {
    let id: UUID
    var title: String
    var words: [JishoWord]
    
    init(id: UUID = UUID(), title: String, words: [JishoWord] = []) {
        self.id = id
        self.title = title
        self.words = words
    }
}
