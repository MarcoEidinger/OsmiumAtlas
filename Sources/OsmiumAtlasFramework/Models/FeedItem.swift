import Foundation

/// abstraction of Atom/RSS/JSON feed item
public protocol FeedItem {
    var title: String? { get }
    var url: String? { get }
    var published_date: Date? { get }
}
