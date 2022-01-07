import Foundation

/// representing a blog / site listed in iOS Dev Directory (https://raw.githubusercontent.com/daveverwer/iOSDevDirectory/master/blogs.json)
public struct Blog: Codable {
    public var title: String
    public var author: String
    public var site_url: String?
    public var feed_url: String?
    public var most_recent_article: Article? // introduced by OsmiumAtlas and is not known to iOS Dev Directory
}

extension Blog: Identifiable {
    public var id: String {
        "\(title)\(author)"
    }
}

extension Blog {
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }

    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        encoder.dateEncodingStrategy = .formatted(Blog.dateFormatter)
        return encoder
    }
}
