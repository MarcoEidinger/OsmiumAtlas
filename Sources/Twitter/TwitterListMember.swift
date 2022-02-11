import Foundation

struct TwitterListMemberDictionary: Decodable {
    var data: [TwitterListMember]
}

struct TwitterListMember: Decodable {
    var id: String
    var name: String
    var username: String
}
