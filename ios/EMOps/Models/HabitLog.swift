import Foundation

struct HabitLog: Codable, Identifiable, Equatable {
    let id: String
    let habitId: String
    let userId: String
    let logDate: String
    let value: Double?
    let isCompleted: Bool
    let notes: String

    enum CodingKeys: String, CodingKey {
        case id
        case habitId = "habit_id"
        case userId = "user_id"
        case logDate = "log_date"
        case value
        case isCompleted = "is_completed"
        case notes
    }
}
