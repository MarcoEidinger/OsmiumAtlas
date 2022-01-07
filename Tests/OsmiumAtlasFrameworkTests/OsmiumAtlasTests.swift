@testable import OsmiumAtlasFramework
import XCTest

final class OsmiumAtlasTests: XCTestCase {
    func testGetEnglishDevelopmentBlogs() async throws {
        let sut = iOSDevDirectoryNetworkingService()
        let blogs = try await sut.getEnglishDevelopmentBlogs()
        XCTAssertTrue(blogs.count > 500)
    }

    func testDetermineLatestPosts() async throws {
        let sut = iOSDevDirectoryNetworkingService()
        let blog = Blog(title: "SwiftyTech", author: "Marco Eidinger", site_url: "https://blog.eidinger.info/", feed_url: "https://blog.eidinger.info/rss.xml", most_recent_article: nil)
        let blogsWithMostRecentArticle = try await sut.blogsWithMostRecentArticle(for: [blog])
        XCTAssertEqual(blogsWithMostRecentArticle.count, 1)
        XCTAssertNotNil(blogsWithMostRecentArticle[0].most_recent_article?.published_date)
    }
}
