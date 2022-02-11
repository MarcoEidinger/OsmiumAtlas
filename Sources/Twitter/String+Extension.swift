import Foundation

public extension String {
    var sanitizedTwitterHandle: String {
        replacingOccurrences(of: "https://twitter.com/", with: "")
            .replacingOccurrences(of: "http://twitter.com/", with: "")
            .replacingOccurrences(of: "https://www.twitter.com/", with: "")
            .replacingOccurrences(of: "http://www.twitter.com/", with: "")
    }
}
