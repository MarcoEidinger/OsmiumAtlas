import Foundation

/// representing the combined information of sites (with most recent article) and its stats
public struct SitesAndStats: Codable {
    public init(sites: [Blog], stats: SitesStats) {
        self.sites = sites
        self.stats = stats
    }

    public var sites: [Blog]
    public var stats: SitesStats

    public func asJson() throws -> String {
        let json = try Blog.encoder.encode(self)
        let jsonString = String(data: json, encoding: .utf8)!
        return jsonString
    }
}
