//
// Created for MyBooks
// by  Stewart Lynch on 2023-10-15
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch


import SwiftUI
import SwiftData

@Model
class Genre: Codable {
    enum CodingKeys: CodingKey {
        case name, color
    }

    var name: String = ""
    var color: String = "FF0000"
    @Relationship(deleteRule: .noAction)
    var books: [Book]?

    init(name: String, color: String) {
        self.name = name
        self.color = color
    }
    
    var hexColor: Color {
        Color(hex: self.color) ?? .red
    }

    required init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            color = try container.decode(String.self, forKey: .color)
        } catch {
            print(error.localizedDescription)
        }
    }

    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(color, forKey: .color)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension Genre: CustomStringConvertible {
    var description: String {
        return name + "\nColor \(color)" + "\nBook Count: \(books?.count ?? 0)"
    }
    

}
