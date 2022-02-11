import ArgumentParser
import Foundation
import OsmiumAtlasFramework

struct iOSDevDirectoryEnglishDevBlogs: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "check-en-dev"
    )

    @Flag(help: "Debug/Verbose logging")
    var debug = false

    mutating func runAsync() async throws {
        do {
            Logger.shared = BeaverLogger.create(verbose: debug, logDestination: .defaultFile)
            let result = try await CLIUtil().getSitesAndStats()
            print(try result.asJson())
        } catch {
            Logger.shared.error(error.localizedDescription)
        }
    }
}
