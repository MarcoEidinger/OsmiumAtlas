import Foundation

struct Blog: Codable {
    var title: String
    var author: String
    var site_url: String?
    var feed_url: String?
    var latestPostDate: Date?
}

extension Blog: Identifiable {
    var id: String {
        return "\(title)\(author)"
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
