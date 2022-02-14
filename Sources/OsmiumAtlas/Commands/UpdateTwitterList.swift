import ArgumentParser
import Foundation
import Logging
import OsmiumAtlasFramework
import Twitter

struct UpdateTwitterList: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "update-twitterlist"
    )

    @Flag(help: "Debug/Verbose logging")
    var debug = false

    @Flag(help: "No changes")
    var dryRun = false

    @Argument(help: "ConsumerKey")
    var consumerKey: String

    @Argument(help: "ConsumerSecret")
    var consumerSecret: String

    @Argument(help: "ConsumerKey")
    var oauthToken: String

    @Argument(help: "ConsumerKey")
    var oauthTokenSecret: String

    mutating func runAsync() async throws {
        setLogger()
        do {
            // 1. download twitter list
            let twitterListId = "1490025783963754502"
            let twitter = Twitter.API(consumerKey: consumerKey, consumerSecret: consumerSecret, oauthToken: oauthToken, oauthTokenSecret: oauthTokenSecret)
            let twitterListMemberUsername = try await twitter.getListMembers(for: twitterListId).map { $0.lowercased() }
            Logger.shared.info("\(twitterListMemberUsername.count) Members in Twitter List: \(twitterListMemberUsername)")

            // 2. download blogs to get recent authors
            Logger.shared.reset()
            let blogs = try await CLIUtil().getSitesAndStats().sites
            let authorTwitterUsername = blogs.compactMap { $0.twitter_url?.sanitizedTwitterHandle.lowercased() }[0 ..< 75]
            setLogger()
            Logger.shared.info("Latest authors: \(authorTwitterUsername)")

            // 3. delta comparison

            let authorTwitterUsernameSet = Set(authorTwitterUsername)
            let twitterListMemberUsernameSet = Set(twitterListMemberUsername)
            let userNamesToBeAdded = authorTwitterUsernameSet.subtracting(twitterListMemberUsernameSet)
            let userNamesToBeRemoved = twitterListMemberUsernameSet.subtracting(authorTwitterUsername)

            Logger.shared.info("\(userNamesToBeAdded.count) people to be added: \(userNamesToBeAdded)")
            Logger.shared.info("\(userNamesToBeRemoved.count) people to be removed: \(userNamesToBeRemoved)")
            Logger.shared.info("new total member count: \(authorTwitterUsernameSet.count) or \(twitterListMemberUsername.count + userNamesToBeAdded.count - userNamesToBeRemoved.count)")

            guard dryRun == false else { return }

            // 4. update twitter list (add/remove members)
            try await updateList(id: twitterListId, adding: Array(userNamesToBeAdded), removing: Array(userNamesToBeRemoved), api: twitter)

        } catch {
            Logger.shared.error(error.localizedDescription)
        }
    }

    func updateList(id listId: String, adding: [String], removing: [String], api: API) async throws {
        _ = try await withThrowingTaskGroup(of: String.self) { group in

            var userIdsToAdd: [String] = []
            var userIdsToRemove: [String] = []

            Logger.shared.info("updating list ...")

            if adding.count > 0 {
                let userIds = try await api.findUsers(screenNames: adding)
                userIdsToAdd.append(contentsOf: userIds)
            }

            if removing.count > 0 {
                let userIds = try await api.findUsers(screenNames: removing)
                userIdsToRemove.append(contentsOf: userIds)
            }

            for userid in userIdsToAdd {
                group.addTask {
                    _ = try await api.addListMember(id: userid, to: listId)
                    return (userid)
                }
            }

            for userid in userIdsToRemove {
                group.addTask {
                    _ = try await api.removeListMember(id: userid, from: listId)
                    return (userid)
                }
            }
        }

        Logger.shared.info("updating list done")

        let twitterListMemberUsername = try await api.getListMembers(for: listId).map { $0.lowercased() }
        Logger.shared.info("\(twitterListMemberUsername.count) Members in Twitter List: \(twitterListMemberUsername)")
    }

    func setLogger() {
        Logger.shared = BeaverLogger.create(verbose: debug, logDestination: .console, format: "$d $C$L$c $M")
    }
}
