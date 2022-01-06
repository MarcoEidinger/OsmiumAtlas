import ArgumentParser
import Foundation

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

struct MainCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "idd-blog-checker",
        abstract: "Repeats your input phrase.",
        discussion: """
        Prints to stdout forever, or until you halt the program.
        """
    )

    @Flag(help: "Verbose")
    var yello = false

    @Flag(help: "Save as updated.json")
    var printInConsole = false

    @Flag(help: "Save as updated.json")
    var saveAsFile = false

    @Flag(help: "Save as updated-<yyyyMMdd>.json")
    var saveAsFileWithVersioning = false

    mutating func runAsync() async throws {
        Logger.shared = BeaverLogger(verbose: yello)
        if !printInConsole && !saveAsFile {
            print("specify either --print-in-console or save-as-file")
            return
        }
        Logger.shared.debug("start")
        do {
            let checker = iDDBlockChecker()
            //checker.stats(filename: "updated.json")

            let blogs = try await checker.getEnglishDevelopmentBlogs()
            Logger.shared.info("English Dev blogs: \(blogs.count)")
            let blogsWithTimestamps = try await checker.determineLatestPosts(for: Array(blogs))
            Logger.shared.info("English Dev blogs with timestamp: \(blogsWithTimestamps.count)")

            if printInConsole {
                print(try blogsWithTimestamps.asJson())
            }
//            if saveAsFile {
//                _ = try blogsWithTimestamps.save(filename: "updated.json")
//            }
//            if saveAsFileWithVersioning {
//                let formatter = DateFormatter()
//                formatter.dateFormat = "yyyyMMdd"
//                _ = try blogsWithTimestamps.save(filename: "updated-\(formatter.string(from: Date())).json")
//            }
        } catch let error{
            Logger.shared.error(error.localizedDescription)
        }
    }
}
