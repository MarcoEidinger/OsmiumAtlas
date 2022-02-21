import AsyncCompatibilityKit
import Foundation
import Logging
import OhhAuth
import Swifter

public struct API {
    private var api: Swifter

    private var consumerKey: String
    private var consumerSecret: String
    private var oauthToken: String
    private var oauthTokenSecret: String

    public init(consumerKey: String, consumerSecret: String, oauthToken: String, oauthTokenSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.oauthToken = oauthToken
        self.oauthTokenSecret = oauthTokenSecret

        api = Swifter(consumerKey: consumerKey, consumerSecret: consumerSecret, oauthToken: oauthToken, oauthTokenSecret: oauthTokenSecret)
    }

    public func getListMembers(for listId: String) async throws -> [String] {
        // using Twitter v2 API to avoid pagination / curser handling
        // but Switter does not support v2 so let's send request directly
        var request = URLRequest(url: URL(string: "https://api.twitter.com/2/lists/\(listId)/members")!)
        request.oAuthSign(method: "GET",
                          urlFormParameters: [:],
                          consumerCredentials: (key: consumerKey, secret: consumerSecret),
                          userCredentials: (key: oauthToken, secret: oauthTokenSecret))
        let (data, _) = try await URLSession.shared.data(for: request as URLRequest)
        let parsedResponse = try JSONDecoder().decode(TwitterListMemberDictionary.self, from: data)
        return parsedResponse.data.map(\.username)
    }

    public func findUsers(screenNames: [String]) async throws -> [String] {
        try await api.lookupIds(of: .screenName(screenNames))
    }

    public func addListMember(id: String, to list: String) async throws {
        try await api.addListMember(userTag: .id(id), to: .id(list))
    }

    public func removeListMember(id: String, from list: String) async throws {
        try await api.removeListMember(.id([id]), from: .id(list))
    }
}

public enum TwitterError: LocalizedError {
    case operationFailed(Error)

    var localizedDescription: String {
        switch self {
        case let .operationFailed(error):
            return error.localizedDescription
        }
    }
}

extension Swifter {
    func lookupIds(of users: UsersTag) async throws -> [String] {
        var userIds: [String] = []
        return try await withCheckedThrowingContinuation { continuation in
            self.lookupUsers(for: users, includeEntities: false) { json in
                guard let resultArray = json.array else {
                    continuation.resume(returning: userIds)
                    return
                }
                for entry in resultArray {
                    if let userId = entry["id_str"].string {
                        if let user = entry["name"].string {
                            Logger.shared.debug("User '\(user)' with id: \(userId)")
                        }
                        userIds.append(userId)
                    }
                }
                continuation.resume(returning: userIds)
            } failure: { error in
                Logger.shared.error("cannot lookup Ids for \(users)" + error.localizedDescription)
                continuation.resume(throwing: TwitterError.operationFailed(error))
            }
        }
    }

    func addListMember(userTag: UserTag, to: ListTag) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.addListMember(userTag, to: to) { json in
                continuation.resume()
            } failure: { error in
                Logger.shared.error("cannot add \(userTag)" + error.localizedDescription)
                continuation.resume()
            }
        }
    }

    func removeListMember(_ usersTag: UsersTag, from: ListTag) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.removeListMembers(usersTag, from: from) { json in
                continuation.resume()
            } failure: { error in
                print("cannot remove \(usersTag)" + error.localizedDescription)
                continuation.resume()
            }
        }
    }
}
