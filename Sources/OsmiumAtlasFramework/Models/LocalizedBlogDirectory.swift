import Foundation

/// representing top-level of iOS Dev Directory (https://raw.githubusercontent.com/daveverwer/iOSDevDirectory/master/blogs.json)
public struct LocalizedBlogDirectory: Decodable {
    public var language: String?
    public var title: String?
    public var categories: [BlogCategory]?
}
