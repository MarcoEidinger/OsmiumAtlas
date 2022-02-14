import Foundation
import Logging
import OsmiumAtlasFramework

struct CLIUtil {
    func getSitesAndStats() async throws -> SitesAndStats {
        let service = iOSDevDirectoryNetworkingService()

        let blogs = try await service.getEnglishDevelopmentBlogs()
        Logger.shared.info("English dev blogs: \(blogs.count)")

        let blogsWithMostRecentArticle = try await service.blogsWithMostRecentArticle(for: Array(blogs))
        Logger.shared.info("English dev blogs with most recent article: \(blogsWithMostRecentArticle.count)")

        let result = SitesAndStats(sites: blogsWithMostRecentArticle,
                                   stats: SitesStats(sites: blogsWithMostRecentArticle))

        return result
    }
}
