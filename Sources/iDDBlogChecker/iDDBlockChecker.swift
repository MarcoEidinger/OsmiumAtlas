import AsyncCompatibilityKit
import Foundation

class iDDBlockChecker {

    private var directoryRemoteFilePath: String

    init(directoryRemoteFilePath: String = "https://raw.githubusercontent.com/daveverwer/iOSDevDirectory/master/blogs.json") {
        self.directoryRemoteFilePath = directoryRemoteFilePath
    }

    func fetchBlogsWithRssFeedItem(for blogs: [Blog]) async -> [Blog] {
        let blogsWithRssFeedItem = await withTaskGroup(of: (Blog).self, returning: [Blog].self) { group in
            for blog in blogs {
                group.addTask {
                    let checkedBlog = await blog.fetchLatestPostDateFromRss()
                    Logger.shared.debug("\(blog.title) checked for timestamp")
                    return (checkedBlog)
                }
            }

            var blogsWithRssFeedItem: [Blog] = []
            for await checkedBlog in group {
                if checkedBlog.latestPostDate != nil {
                    blogsWithRssFeedItem.append(checkedBlog)
                }
            }
            Logger.shared.debug("All blogs checked for timestamp")
            return blogsWithRssFeedItem
        }
        return blogsWithRssFeedItem
    }

    func determineLatestPosts(for blogs: [Blog]) async throws -> [Blog] {
        var updatedBlogs = blogs
        let startDate = Date()
        updatedBlogs = await fetchBlogsWithRssFeedItem(for: blogs)
//        for try await item in BlogRssFeedProvider(blogs: Array(updatedBlogs)) {
//            if item.latestPostDate != nil {
//                updatedBlogs.append(item)
//            }
//        }
        let endDate = Date()
        let differenceInSeconds = Int(endDate.timeIntervalSince(startDate))
        Logger.shared.debug("Performance: \(differenceInSeconds) seconds")

        updatedBlogs = updatedBlogs.filter { $0.latestPostDate != nil }
        let updatedBlogsSorted = updatedBlogs.sorted(by: { $0.latestPostDate!.compare($1.latestPostDate!) == .orderedDescending })

        return updatedBlogsSorted
    }

    func getLocalizedBlogDirectories() async throws -> [LocalizedBlogDirectory] {
        guard let url = URL(string: self.directoryRemoteFilePath) else { fatalError() }
        let result = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([LocalizedBlogDirectory].self, from: result.0)
    }

    func getEnglishDevelopmentBlogs() async throws -> [Blog] {
        let localizedBlogDirectories = try await getLocalizedBlogDirectories()
        guard let englishBlogDirectory = localizedBlogDirectories.first(where: { $0.language == "en" }) else { return [] }
        guard let devCategory = englishBlogDirectory.categories?.first(where: { $0.slug == "development" }) else { return [] }
        guard let devBlogs = devCategory.sites else { return [] }
        return devBlogs
    }

    func stats(filename: String) {
        let filePath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(filename)
        do {
            guard let jsonData = try String(contentsOf: filePath, encoding: .utf8).data(using: .utf8) else { fatalError() }
            print(try String(contentsOf: filePath, encoding: .utf8))
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(Blog.dateFormatter)
            let blogs = try decoder.decode([Blog].self, from: jsonData)
            blogs.printStats()
        } catch let error {
            Logger.shared.debug(error.localizedDescription)
        }
    }
}
