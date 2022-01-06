import Foundation

extension Array where Element == Blog {
    func save(filename: String) throws -> URL {
        let filePath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(filename)

        let json = try Blog.encoder.encode(self)
        let jsonString = String(data: json, encoding: .utf8)!
        try jsonString.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)

        return filePath
    }

    func asJson() throws -> String {
        let json = try Blog.encoder.encode(self)
        let jsonString = String(data: json, encoding: .utf8)!
        return jsonString
    }

    func numberOfBlogsWithLatestPosWrittenSince(days: Int) -> Int {
        guard let fromDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) else { fatalError() }
        let blogsWithDates = self.filter({ $0.latestPostDate != nil })
        return blogsWithDates.filter({ $0.latestPostDate! >= fromDate }).count
    }

    var total: Int {
        self.count
    }
    var blogsActive30Days: Int {
        self.numberOfBlogsWithLatestPosWrittenSince(days: 30)
    }
    var blogsActive60Days: Int {
        self.numberOfBlogsWithLatestPosWrittenSince(days: 60)
    }
    var blogsActive90Days: Int {
        self.numberOfBlogsWithLatestPosWrittenSince(days: 90)
    }
    var blogsActive30DaysPercentage: Double {
        Double(blogsActive30Days) / Double(total) * 100
    }
    var blogsActive60DaysPercentage: Double {
        Double(blogsActive60Days) / Double(total) * 100
    }
    var blogsActive90DaysPercentage: Double {
        Double(blogsActive90Days) / Double(total) * 100
    }

    func printStats() {
        print("Number of Blogs: \(self.total)")
        print("Number of Blogs with posts within 30 days: \(self.blogsActive30Days)")
        print("Number of Blogs with posts within 60 days: \(self.blogsActive60Days)")
        print("Number of Blogs with posts within 90 days: \(self.blogsActive90Days)")
        print("% of Blogs with posts within 30 days: \(self.blogsActive30DaysPercentage)")
        print("% of Blogs with posts within 60 days: \(self.blogsActive60DaysPercentage)")
        print("% of Blogs with posts within 90 days: \(self.blogsActive90DaysPercentage)")
    }
}
