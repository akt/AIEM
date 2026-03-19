import Foundation

struct Reminder: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let title: String
    let body: String
    let scheduledAt: String
    let type: String
    let delivered: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case body
        case scheduledAt = "scheduled_at"
        case type
        case delivered
    }
}
