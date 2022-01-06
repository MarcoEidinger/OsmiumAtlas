import FeedKit
import Foundation

extension Blog {
    func fetchLatestPostDateFromRss() async -> Blog {
        var blog = self
        guard let feedUrl = blog.feed_url else { return blog }
        let feedURL = URL(string: feedUrl)!
        let parser = FeedParser(URL: feedURL)
        let date = await parser.asyncParse(for: blog)
        blog.latestPostDate = date

        return blog
    }
}

extension FeedParser {
    func asyncParse(for blog: Blog) async -> Date? {
        return await withCheckedContinuation { continuation in
            // then, we call the original fetchData
            self.parseAsync(queue: DispatchQueue(label: "swiftlee.concurrent.queue", attributes: .concurrent)) { result in

                var optionalDate: Date?

                switch result {
                case let .success(feed):

                    switch feed {
                    case let .atom(feed): // Atom Syndication Format Feed Model
                        optionalDate = feed.entries?.first?.updated
                    case let .rss(feed): // Really Simple Syndication Feed Model
                        optionalDate = feed.items?.first?.pubDate
                    case let .json(feed): // JSON Feed Model
                        optionalDate = feed.items?.first?.datePublished
                    }

                    continuation.resume(returning: optionalDate)

                case .failure(let meep):
                    Logger.shared.error("Error \(meep.localizedDescription) - \(meep.errorDescription ?? "") for trying to determine last post date for blog \(blog.title)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

struct BlogRssFeedProvider: AsyncSequence {
    typealias Element = Blog

    let blogs: [Blog]

    func makeAsyncIterator() -> BlogRssFeedIterator {
        return BlogRssFeedIterator(blogs: blogs)
    }
}

struct BlogRssFeedIterator: AsyncIteratorProtocol {
    typealias Element = Blog

    let blogs: [Blog]
    var index: Int

    init(blogs: [Blog]) {
        self.blogs = blogs
        index = -1
    }

    mutating func next() async throws -> Blog? {
        index += 1
        guard index < blogs.count else { return nil }

        let blog = blogs[index]
        var blogWithPotentialDate = blog
        guard let feedUrl = blog.feed_url else { return blog }
        let feedURL = URL(string: feedUrl)!
        let parser = FeedParser(URL: feedURL)
        let date = await parser.asyncParse(for: blog)
        blogWithPotentialDate.latestPostDate = date
        Logger.shared.debug("\(index) out of \(blogs.count) blogs checked for timestamp")
        return blogWithPotentialDate
    }
}
