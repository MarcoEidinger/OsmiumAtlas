import Foundation

struct BlogCategory: Decodable {
    var title: String?
    var slug: String?
    var sites: [Blog]?
}
