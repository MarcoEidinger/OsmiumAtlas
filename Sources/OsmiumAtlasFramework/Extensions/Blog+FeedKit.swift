import FeedKit
import Foundation

extension Blog {
    /// performs network call to retrieve Atom/RSS/JSON feed, parses it and returns original object with `most_recent_article` (if available)
    func fetchLatestPostDateFromRss() async -> Blog {
        var blog = self
        guard let feedUrl = blog.feed_url else { return blog }
        let feedURL = URL(string: feedUrl)!
        let parser = FeedParser(URL: feedURL)
        let latestFeedItem = await parser.asyncParse(for: blog)
        guard let lfi = latestFeedItem else { return blog }
        blog.most_recent_article = Article(feedItem: lfi)
        return blog
    }
}
