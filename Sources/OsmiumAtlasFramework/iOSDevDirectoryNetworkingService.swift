import AsyncCompatibilityKit
import Foundation

/// main API for command-line tool
public class iOSDevDirectoryNetworkingService {
    private var directoryRemoteFilePath: String = "https://raw.githubusercontent.com/daveverwer/iOSDevDirectory/master/blogs.json"

    public init() {}

    /// fetch (networking call) all development blogs, written in English, from iOS Dev Directory
    /// - Returns: all development blogs (written in English) listed in iOS Dev Directory
    public func getEnglishDevelopmentBlogs() async throws -> [Blog] {
        let localizedBlogDirectories = try await getLocalizedBlogDirectories()
        guard let englishBlogDirectory = localizedBlogDirectories.first(where: { $0.language == "en" }) else { return [] }
        guard let devCategory = englishBlogDirectory.categories?.first(where: { $0.slug == "development" }) else { return [] }
        guard let devBlogs = devCategory.sites else { return [] }
        return devBlogs
    }

    /// Performs network calls to blog sites to determine its most recent article from RSS feed
    /// - Parameter blogs: blog entries with no `most_recent_article`
    /// - Returns: subset of `blogs` (as not all blogs may have RSS feed),  subset is ordered by `most_recent_article.published_date` (decending) and entries are guaranteed to have `most_recent_article`
    public func blogsWithMostRecentArticle(for blogs: [Blog]) async throws -> [Blog] {
        let startDate = Date()
        let blogsWithMostRecentArticle = await fetchBlogsWithRssFeedItem(for: blogs)
        let endDate = Date()
        let differenceInSeconds = Int(endDate.timeIntervalSince(startDate))
        Logger.shared.debug("Performance: \(differenceInSeconds) seconds")

        let sortedBlogsWithMostRecentArticle = blogsWithMostRecentArticle.sorted(by: { $0.most_recent_article!.published_date!.compare($1.most_recent_article!.published_date!) == .orderedDescending })

        return sortedBlogsWithMostRecentArticle
    }

    func getLocalizedBlogDirectories() async throws -> [LocalizedBlogDirectory] {
        guard let url = URL(string: directoryRemoteFilePath) else { fatalError() }
        let result = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([LocalizedBlogDirectory].self, from: result.0)
    }

    /// Perform network calls to blog site to retrieve RSS feed and most recent article
    /// - Parameter blogs: blog entries with no `most_recent_article`
    /// - Returns: subset of `blogs` and  subset entries are guaranteed to have `most_recent_article`
    func fetchBlogsWithRssFeedItem(for blogs: [Blog]) async -> [Blog] {
        let blogsWithRssFeedItem = await withTaskGroup(of: Blog.self, returning: [Blog].self) { group in
            for blog in blogs {
                group.addTask {
                    let checkedBlog = await blog.fetchLatestPostDateFromRss()
                    Logger.shared.debug("\(blog.title) checked for timestamp")
                    return (checkedBlog)
                }
            }

            var blogsWithRssFeedItem: [Blog] = []
            for await checkedBlog in group {
                if checkedBlog.most_recent_article?.published_date != nil {
                    blogsWithRssFeedItem.append(checkedBlog)
                }
            }
            Logger.shared.debug("All blogs checked for timestamp")
            return blogsWithRssFeedItem
        }
        return blogsWithRssFeedItem
    }
}
