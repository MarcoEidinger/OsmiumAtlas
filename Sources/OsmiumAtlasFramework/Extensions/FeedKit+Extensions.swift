import FeedKit
import Foundation
import Logging

extension FeedParser {
    func asyncParse(for blog: Blog) async -> FeedItem? {
        await withCheckedContinuation { continuation in
            self.parseAsync(queue: DispatchQueue(label: "osmiumatlas.concurrent.queue", attributes: .concurrent)) { result in

                var latestFeedIten: FeedItem?

                switch result {
                case let .success(feed):

                    switch feed {
                    case let .atom(feed): // Atom Syndication Format Feed Model
                        latestFeedIten = feed.entries?.first
                    case let .rss(feed): // Really Simple Syndication Feed Model
                        latestFeedIten = feed.items?.first
                    case let .json(feed): // JSON Feed Model
                        latestFeedIten = feed.items?.first
                    }

                    continuation.resume(returning: latestFeedIten)

                case let .failure(error):
                    Logger.shared.error("Error \(error.localizedDescription) - \(error.errorDescription ?? "") for trying to determine last post date for blog \(blog.title)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

extension AtomFeedEntry: FeedItem {
    public var url: String? {
        id
    }

    public var published_date: Date? {
        published
    }
}

extension RSSFeedItem: FeedItem {
    public var url: String? {
        link
    }

    public var published_date: Date? {
        pubDate
    }
}

extension JSONFeedItem: FeedItem {
    public var published_date: Date? {
        datePublished
    }
}
