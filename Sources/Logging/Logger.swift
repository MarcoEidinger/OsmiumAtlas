import Foundation
import SwiftyBeaver

public enum LogDestination {
    case console
    case defaultFile
    case file(URL)
}

public struct BeaverLogger {
    private(set) var logLevel: LogLevel

    private(set) var log: SwiftyBeaver.Type

    internal init(into destination: LogDestination = .console,
                  verbose: Bool,
                  format: String)
    {
        logLevel = verbose ? .debug : .error

        log = SwiftyBeaver.self

        log.addDestination(make(destination, format: format))
    }

    func make(_ destination: LogDestination, format: String) -> BaseDestination {
        let createdDestination: BaseDestination
        switch destination {
        case .defaultFile:
            createdDestination = FileDestination(logFileURL: URL(fileURLWithPath: "/tmp/iosdevdirectory.log"))
        case let .file(url):
            createdDestination = FileDestination(logFileURL: url)
        default:
            createdDestination = ConsoleDestination()
        }

        createdDestination.format = format

        return createdDestination
    }

    public static func create(verbose: Bool,
                              logDestination: LogDestination = .defaultFile,
                              format: String = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M") -> Logging
    {
        BeaverLogger(into: logDestination, verbose: verbose, format: format)
    }
}

extension BeaverLogger: Logging {
    public func error(_ message: String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        guard logLevel >= .error else { return }
        log.error(message, file, function, line: line)
    }

    public func warning(_ message: String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        guard logLevel >= .warning else { return }
        log.warning(message, file, function, line: line)
    }

    public func info(_ message: String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        guard logLevel >= .info else { return }
        log.info(message, file, function, line: line)
    }

    public func debug(_ message: String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        guard logLevel >= .debug else { return }
        log.debug(message, file, function, line: line)
    }

    public func reset() {
        log.removeAllDestinations()
    }
}

/// A log level can be used to make logging conditional, e.g. only errors with log level `error` but log infos, warning and errors with log level `info`
public enum LogLevel: Comparable {
    /// error
    case error
    /// warning
    case warning
    /// info
    case info
    /// debug
    case debug
}

/// common interface for Loggers
public protocol Logging {
    /// log an error
    /// - Parameters:
    ///   - message: to be logged
    ///   - file: in which the message occurred
    ///   - function: in wich the message occurred
    ///   - line: line number in which the message occurred
    /// - Parameter message: to be logged
    func error(_ message: String, _ file: String, _ function: String, _ line: Int)

    /// log a warning
    /// - Parameters:
    ///   - message: to be logged
    ///   - file: in which the message occurred
    ///   - function: in wich the message occurred
    ///   - line: line number in which the message occurred
    func warning(_ message: String, _ file: String, _ function: String, _ line: Int)

    /// log an info
    /// - Parameters:
    ///   - message: to be logged
    ///   - file: in which the message occurred
    ///   - function: in wich the message occurred
    ///   - line: line number in which the message occurred
    func info(_ message: String, _ file: String, _ function: String, _ line: Int)

    /// log debugging-related info
    /// - Parameters:
    ///   - message: to be logged
    ///   - file: in which the message occurred
    ///   - function: in wich the message occurred
    ///   - line: line number in which the message occurred
    func debug(_ message: String, _ file: String, _ function: String, _ line: Int)

    func reset()
}

/// :nodoc:
public extension Logging {
    /// :nodoc:
    func error(_ message: String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        error(message, file, function, line)
    }

    /// :nodoc:
    func warning(_ message: String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        warning(message, file, function, line)
    }

    /// :nodoc:
    func info(_ message: String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        info(message, file, function, line)
    }

    /// :nodoc:
    func debug(_ message: String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        debug(message, file, function, line)
    }

    func reset() {}
}

/// :nodoc:
public enum Logger {
    /// singleton to access logger
    public static var shared: Logging = NoLogger()
}
