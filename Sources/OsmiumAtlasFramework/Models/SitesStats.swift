import Foundation

/// representing the statistics of the sites / blogs with respect to recent activity
public struct SitesStats: Codable {
    public var sites_total: Int = 0
    public var sites_active_30d: Int = 0
    public var sites_active_60d: Int = 0
    public var sites_active_90d: Int = 0
    public var sites_active_30d_in_percentage: Double = 0
    public var sites_active_60d_in_percentage: Double = 0
    public var sites_active_90d_in_percentage: Double = 0

    public init(sites: [Blog]) {
        sites_total = sites.count
        sites_active_30d = numberOfSitesWithMostRecentArticleWithin(days: 30, sites: sites)
        sites_active_60d = numberOfSitesWithMostRecentArticleWithin(days: 60, sites: sites)
        sites_active_90d = numberOfSitesWithMostRecentArticleWithin(days: 90, sites: sites)
        sites_active_30d_in_percentage = round(Double(sites_active_30d) / Double(sites_total) * 100)
        sites_active_60d_in_percentage = round(Double(sites_active_60d) / Double(sites_total) * 100)
        sites_active_90d_in_percentage = round(Double(sites_active_90d) / Double(sites_total) * 100)
    }

    func numberOfSitesWithMostRecentArticleWithin(days: Int, sites: [Blog]) -> Int {
        guard let fromDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) else { fatalError() }
        let blogsWithDates = sites.filter { $0.most_recent_article?.published_date != nil }
        return blogsWithDates.filter { $0.most_recent_article!.published_date! >= fromDate }.count
    }
}
