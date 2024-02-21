//
// Created for MyBooks
// by  Stewart Lynch on 2023-10-03
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch


import SwiftUI
import SwiftData
import Compression
import os.log

// Cloudkit requires values for all properties
// All relationships must be optional
// Cloudkit cannot have a @Unique property
@Model
class Book: Codable {
    var title: String = ""
    var author: String = ""
    var dateAdded: Date = Date.now
    var dateStarted: Date = Date.distantPast
    var dateCompleted: Date = Date.distantPast
    @Attribute(originalName: "summary")
    var synopsis: String = ""
    var rating: Int?
    var status: Status.RawValue = Status.onShelf.rawValue
    var recommendedBy: String = ""
    @Relationship(deleteRule: .cascade)
    var quotes: [Quote]?
    @Relationship(inverse: \Genre.books)
    var genres: [Genre]?
//    @Relationship(inverse: \Actor.books)
//    var actors: [Actor]?


    enum CodingKeys: CodingKey {
        case title ,author ,dateAdded ,dateStarted ,dateCompleted ,synopsis ,rating ,status ,recommendedBy ,quotes ,genres, actors
    }


    required init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: .title)
            author = try container.decode(String.self, forKey: .author)
            dateAdded = try container.decode(Date.self, forKey: .dateAdded)
            dateStarted = try container.decode(Date.self, forKey: .dateStarted)
            dateCompleted = try container.decode(Date.self, forKey: .dateCompleted)
            synopsis = try container.decode(String.self, forKey: .synopsis)
            rating = try container.decode(Int?.self, forKey: .rating)
            let statusRaw = try container.decode(Int.self, forKey: .status)
            if let status = Status(rawValue: statusRaw) {
                self.status = status.rawValue
            }

            recommendedBy = try container.decode(String.self, forKey: .recommendedBy)
            quotes = try container.decode([Quote]?.self, forKey: .quotes)
            genres = try container.decode([Genre]?.self, forKey: .genres)
//            actors = try container.decode([Actor]?.self, forKey: .actors)
        } catch {
            print(error.localizedDescription)
        }
    }

    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .title)
            try container.encode(author, forKey: .author)
            try container.encode(dateAdded, forKey: .dateAdded)
            try container.encode(dateStarted, forKey: .dateStarted)
            try container.encode(dateCompleted, forKey: .dateCompleted)
            try container.encode(synopsis, forKey: .synopsis)
            try container.encode(rating, forKey: .rating)
            try container.encode(status, forKey: .status)
            try container.encode(recommendedBy, forKey: .recommendedBy)
            try container.encode(quotes, forKey: .quotes)
            try container.encode(genres, forKey: .genres)
//            try container.encode(actors, forKey: .actors)
        } catch {
            print(error.localizedDescription)
        }
    }

    init(
        title: String = "",
        author: String = "",
        dateAdded: Date = Date.now,
        dateStarted: Date = Date.distantPast,
        dateCompleted: Date = Date.distantPast,
        synopsis: String = "",
        rating: Int? = nil,
        status: Status = .onShelf,
        recommendedBy: String = ""
    ) {
        self.title = title
        self.author = author
        self.dateAdded = dateAdded
        self.dateStarted = dateStarted
        self.dateCompleted = dateCompleted
        self.synopsis = synopsis
        self.rating = rating
        self.status = status.rawValue
        self.recommendedBy = recommendedBy
    }
    
    var icon: Image {
        switch Status(rawValue: status)! {
        case .onShelf:
            Image(systemName: "checkmark.diamond.fill")
        case .inProgress:
            Image(systemName: "book.fill")
        case .completed:
            Image(systemName: "books.vertical.fill")
        }
    }
}


enum Status: Int, Codable, Identifiable, CaseIterable {
    case onShelf, inProgress, completed
    var id: Self {
        self
    }
    var descr: LocalizedStringResource {
        switch self {
        case .onShelf:
            "On Shelf"
        case .inProgress:
            "In Progress"
        case .completed:
            "Completed"
        }
    }
}

extension Book: CustomStringConvertible {
    var description: String {
        return title + "\n" + author + "\nStatus: \(status)" + "\nQuotes: \(String(describing: quotes))" + "\nGenre: \(String(describing: genres))" // + "\nActors: \(actors?.count)"
    }
}

extension Book {
    /// Creates a userInfo object for transmission using WCSession
    /// - Returns: A dictionary with either a compressed entry for
    /// a JSON encoded trip or an uncompressed for older iOS version
    func packageDataForTransferToWatch() -> [String : Any]? {
        // Serialize the watchData into an NSDictionary for transfer to watch
        let book = self

        guard let jsonData = try? JSONEncoder().encode(book) else { return nil }
        var userInfo = [String : Any]()

        do {
            let compressedData = try (jsonData as NSData).compressed(using: .zlib)
            userInfo["TextCodable"] = compressedData
        } catch {
            os_log("Trip compression Error")
        }

        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString) // Prints the JSON string
        }

        return userInfo
    }

    /// Class function, decodes an encoded and/or compressed Trip
    static func unpackageData(userInfo: [String: Any]) -> Book? {
        var book : Book?

        if let data = userInfo["TextCodable"] as? Data {
            os_log("unpackageData compressedTrip")
            do {
                let decompressedData = try (data as NSData).decompressed(using: .zlib)
                book = try JSONDecoder().decode(Book.self, from: decompressedData as Data)
            } catch {
                os_log("Error Decompressing or decoding trip")
            }
        }
        return book
    }

    // iOS 12+ compatible compress/decompress routines; require that
    // the size of the original data structure is sent to the watch.
    // Not implemented yet.
    static func compressData(for data: Data) -> Data? {
        let byteSize = MemoryLayout<UInt8>.stride
        let bufferSize = data.count / byteSize
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        var sourceBuffer = Array<UInt8>(repeating: 0, count: bufferSize)
        data.copyBytes(to: &sourceBuffer, count: data.count)

        let compressedSize = compression_encode_buffer(destinationBuffer,
                                                       data.count,
                                                       &sourceBuffer,
                                                       data.count,
                                                       nil,
                                                       COMPRESSION_ZLIB)
        guard compressedSize != 0 else { return nil}
        let encodeData : Data = NSData(bytesNoCopy: destinationBuffer, length: compressedSize) as Data

        return encodeData
    }
    static func uncompressData(for data: Data, originalSize: Int) -> Data? {
        let bufferSize = originalSize
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        var sourceBuffer = Array<UInt8>(repeating: 0, count: bufferSize)

        let _ = compression_decode_buffer(destinationBuffer,
                                          originalSize,
                                          &sourceBuffer,
                                          data.count,
                                          nil,
                                          COMPRESSION_ZLIB)
        let decodedData : Data = NSData(bytesNoCopy: destinationBuffer, length: originalSize) as Data
        return decodedData
    }
}
