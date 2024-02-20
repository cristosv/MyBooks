//
// Created for MyBooks
// by  Stewart Lynch on 2023-10-10
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch


import Foundation
import SwiftData

@Model
class Quote: Codable {
    enum CodingKeys: CodingKey {
        case text, page, creationDate
    }

    var text: String = ""
    var page: String = ""
    var creationDate: Date = Date.now
    @Relationship(deleteRule: .nullify)
    var book: Book?

    init(text: String, page: String = "") {
        self.text = text
        self.page = page
        self.creationDate = Date.now
    }
    
    required init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            text = try container.decode(String.self, forKey: .text)
            page = try container.decode(String.self, forKey: .page)
            creationDate = try container.decode(Date.self, forKey: .creationDate)
        } catch {
            print(error.localizedDescription)
        }
    }

    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(text, forKey: .text)
            try container.encode(page, forKey: .page)
            try container.encode(creationDate, forKey: .creationDate)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension Quote: CustomStringConvertible {
    var description: String {
        return text + "\n Page: \(page)"
    }
}
