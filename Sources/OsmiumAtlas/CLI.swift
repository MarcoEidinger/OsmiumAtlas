import ArgumentParser
import Foundation
import OsmiumAtlasFramework

protocol AsyncParsableCommand: ParsableCommand {
    mutating func runAsync() async throws
}

extension ParsableCommand {
    static func main(_ arguments: [String]? = nil) async {
        do {
            var command = try parseAsRoot(arguments)
            if #available(macOS 11.0, *), var asyncCommand = command as? AsyncParsableCommand {
                try await asyncCommand.runAsync()
            } else {
                try command.run()
            }
        } catch {
            exit(withError: error)
        }
    }
}

@main
enum MainApp {
    static func main() async {
        var arguments = CommandLine.arguments
        _ = arguments.removeFirst()
        await MainCommand.main(arguments)
    }
}

struct MainCommand: ParsableCommand {
    // Customize your command's help and subcommands by implementing the
    // `configuration` property.
    static var configuration = CommandConfiguration(
        // Pass an array to `subcommands` to set up a nested tree of subcommands.
        // With language support for type-level introspection, this could be
        // provided by automatically finding nested `ParsableCommand` types.
        subcommands: [iOSDevDirectoryEnglishDevBlogs.self],

        // A default subcommand, when provided, is automatically selected if a
        // subcommand is not given on the command line.
        defaultSubcommand: iOSDevDirectoryEnglishDevBlogs.self
    )
}

struct iOSDevDirectoryEnglishDevBlogs: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "check-en-dev"
    )

    @Flag(help: "Debug/Verbose logging")
    var debug = false

    mutating func runAsync() async throws {
        Logger.shared = BeaverLogger.create(verbose: debug)

        Logger.shared.debug("start")
        do {
            let service = iOSDevDirectoryNetworkingService()

            let blogs = try await service.getEnglishDevelopmentBlogs()
            Logger.shared.info("English dev blogs: \(blogs.count)")
            let blogsWithMostRecentArticle = try await service.blogsWithMostRecentArticle(for: Array(blogs))
            Logger.shared.info("English dev blogs with most recent article: \(blogsWithMostRecentArticle.count)")

            let result = SitesAndStats(sites: blogsWithMostRecentArticle,
                                       stats: SitesStats(sites: blogsWithMostRecentArticle))

            print(try result.asJson())

        } catch {
            Logger.shared.error(error.localizedDescription)
        }
    }
}
