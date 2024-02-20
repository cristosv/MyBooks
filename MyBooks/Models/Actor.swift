////
////  Movies.swift
////  MyBooks
////
////  Created by Cristos Vasilas on 2/20/24.
////
//
import SwiftData
import Foundation

@Model final class Actor: Codable {
    enum CodingKeys: CodingKey {
        case name
    }

    let name: String

    @Relationship(deleteRule: .nullify)
    var books: Book?

    init(name: String, books: Book) {
        self.name = name
        self.books = books
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}

extension Actor: CustomStringConvertible {
    var description: String {
        return "name: \(name)"
    }
}
