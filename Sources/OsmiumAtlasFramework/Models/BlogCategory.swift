import Foundation

/// representing a category as defined in iOS Dev Directory (https://raw.githubusercontent.com/daveverwer/iOSDevDirectory/master/blogs.json)
public struct BlogCategory: Decodable {
    public var title: String?
    public var slug: String?
    public var sites: [Blog]?
}
