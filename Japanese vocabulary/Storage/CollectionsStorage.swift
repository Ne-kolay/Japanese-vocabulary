import Foundation

final class CollectionsStorage {
    static let shared = CollectionsStorage()
    
    private let key = "saved_collections"
    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - Основные методы

    func getAll() -> [WordCollection] {
        guard let data = defaults.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([WordCollection].self, from: data)
        } catch {
            print("Ошибка декодирования коллекций:", error)
            return []
        }
    }

    func save(_ collections: [WordCollection]) {
        do {
            let data = try JSONEncoder().encode(collections)
            defaults.set(data, forKey: key)
        } catch {
            print("Ошибка сохранения коллекций:", error)
        }
    }

    func createCollection(title: String) -> WordCollection {
        var collections = getAll()
        let new = WordCollection(title: title)
        collections.append(new)
        save(collections)
        return new
    }

    func addWord(_ word: JishoWord, to collectionId: UUID) {
        var collections = getAll()
        guard let index = collections.firstIndex(where: { $0.id == collectionId }) else { return }

        // Не добавляем слово, если уже есть
        if !collections[index].words.contains(where: { $0.slug == word.slug }) {
            collections[index].words.append(word)
            save(collections)
        }
    }

    func removeWord(_ word: JishoWord, from collectionId: UUID) {
        var collections = getAll()
        guard let index = collections.firstIndex(where: { $0.id == collectionId }) else { return }

        collections[index].words.removeAll { $0.slug == word.slug }
        save(collections)
    }

    func deleteCollection(id: UUID) {
        var collections = getAll()
        collections.removeAll { $0.id == id }
        save(collections)
    }
}
