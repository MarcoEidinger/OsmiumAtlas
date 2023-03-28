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
        let article = Article(feedItem: lfi)
        guard let published_date = article.published_date, published_date < Date() else { return blog }
        blog.most_recent_article = article
        return blog
    }
}
