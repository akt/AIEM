import Foundation

enum HabitCategory: String, Codable, CaseIterable {
    case deepWork = "deep_work"
    case reliability
    case delivery
    case security
    case aiSafety = "ai_safety"
    case leadership
    case health
    case learning
}

struct Habit: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let name: String
    let description: String
    let category: HabitCategory
    let frequency: Frequency
    let customDays: [String]?
    let targetValue: Double
    let targetUnit: TargetUnit
    let reminderTime: String?
    let reminderEnabled: Bool
    let streakCurrent: Int
    let streakBest: Int
    let isActive: Bool
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case description
        case category
        case frequency
        case customDays = "custom_days"
        case targetValue = "target_value"
        case targetUnit = "target_unit"
        case reminderTime = "reminder_time"
        case reminderEnabled = "reminder_enabled"
        case streakCurrent = "streak_current"
        case streakBest = "streak_best"
        case isActive = "is_active"
        case sortOrder = "sort_order"
    }

    enum Frequency: String, Codable, CaseIterable {
        case daily
        case weekday
        case weekly
        case custom
    }

    enum TargetUnit: String, Codable, CaseIterable {
        case hours
        case count
        case boolean
        case percentage
    }
}
