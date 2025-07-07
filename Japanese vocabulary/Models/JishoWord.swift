import Foundation

struct JishoResponse: Codable {
    let data: [JishoWord]
}

struct JishoWord: Codable {
    let slug: String
    let isCommon: Bool?
    let jlpt: [String]?
    let japanese: [JapaneseElement]
    let senses: [Sense]
}

struct JapaneseElement: Codable {
    let word: String?
    let reading: String?
}

struct Sense: Codable {
    let englishDefinitions: [String]
    let partsOfSpeech: [String]
    let links: [Link]?   // ссылки, включая Википедию, если есть

    enum CodingKeys: String, CodingKey {
        case englishDefinitions = "english_definitions"
        case partsOfSpeech = "parts_of_speech"
        case links
    }
}

struct Link: Codable {
    let text: String
    let url: String
}
