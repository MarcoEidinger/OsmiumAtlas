import Foundation

struct LocalizedBlogDirectory: Decodable {
    var language: String?
    var title: String?
    var categories: [BlogCategory]?
}
