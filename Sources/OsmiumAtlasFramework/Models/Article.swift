import Foundation

/// representing a post on a blog / site
public struct Article: FeedItem, Codable {
    internal init(title: String?, url: String?, publishedDate: Date? = nil) {
        self.title = title
        self.url = url
        published_date = publishedDate
    }

    init(feedItem: FeedItem) {
        title = feedItem.title
        url = feedItem.url
        published_date = feedItem.published_date
    }

    public var title: String?
    public var url: String?
    public var published_date: Date?
}
