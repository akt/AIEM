import Foundation

struct TrendData: Codable, Equatable {
    let weekStart: String
    let deepWorkHoursTotal: Double
    let dsaaRitualsCompleted: Int
    let habitsCompletionRate: Double
    let outcomesCompleted: Int
    let outcomesTotal: Int
    let decisionsMade: Int
    let decisionsTotal: Int
    let incidentsReviewed: Bool
    let errorBudgetStatus: String
    let doraScores: [String: AnyCodable]
    let aiAssistsCount: Int
    let streakDays: Int
    let frictionPulseAvg: Double
    let aiTrendInsight: String?

    enum CodingKeys: String, CodingKey {
        case weekStart = "week_start"
        case deepWorkHoursTotal = "deep_work_hours_total"
        case dsaaRitualsCompleted = "dsaa_rituals_completed"
        case habitsCompletionRate = "habits_completion_rate"
        case outcomesCompleted = "outcomes_completed"
        case outcomesTotal = "outcomes_total"
        case decisionsMade = "decisions_made"
        case decisionsTotal = "decisions_total"
        case incidentsReviewed = "incidents_reviewed"
        case errorBudgetStatus = "error_budget_status"
        case doraScores = "dora_scores"
        case aiAssistsCount = "ai_assists_count"
        case streakDays = "streak_days"
        case frictionPulseAvg = "friction_pulse_avg"
        case aiTrendInsight = "ai_trend_insight"
    }
}

struct AnyCodable: Codable, Equatable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }

    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case is (NSNull, NSNull):
            return true
        case let (l as Bool, r as Bool):
            return l == r
        case let (l as Int, r as Int):
            return l == r
        case let (l as Double, r as Double):
            return l == r
        case let (l as String, r as String):
            return l == r
        default:
            return false
        }
    }
}

struct HabitWithLog: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let name: String
    let description: String
    let category: HabitCategory
    let frequency: Habit.Frequency
    let customDays: [String]?
    let targetValue: Double
    let targetUnit: Habit.TargetUnit
    let reminderTime: String?
    let reminderEnabled: Bool
    let streakCurrent: Int
    let streakBest: Int
    let isActive: Bool
    let sortOrder: Int
    let todayLog: HabitLog?

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
        case todayLog = "today_log"
    }
}

struct TodayHabits: Codable, Equatable {
    let total: Int
    let completed: Int
    let habits: [HabitWithLog]

    enum CodingKeys: String, CodingKey {
        case total
        case completed
        case habits
    }
}

struct WeeklyProgress: Codable, Equatable {
    let outcomesCompleted: Int
    let outcomesTotal: Int
    let deepWorkHoursThisWeek: Double
    let deepWorkHoursTarget: Double

    enum CodingKeys: String, CodingKey {
        case outcomesCompleted = "outcomes_completed"
        case outcomesTotal = "outcomes_total"
        case deepWorkHoursThisWeek = "deep_work_hours_this_week"
        case deepWorkHoursTarget = "deep_work_hours_target"
    }
}

struct DashboardData: Codable, Equatable {
    let currentSheet: WeeklySheet?
    let todayHabits: TodayHabits
    let dsaaStreak: Int
    let todayDsaa: DsaaLog?
    let upcomingReminders: [Reminder]
    let aiCoachingNote: String?
    let weeklyProgress: WeeklyProgress

    enum CodingKeys: String, CodingKey {
        case currentSheet = "current_sheet"
        case todayHabits = "today_habits"
        case dsaaStreak = "dsaa_streak"
        case todayDsaa = "today_dsaa"
        case upcomingReminders = "upcoming_reminders"
        case aiCoachingNote = "ai_coaching_note"
        case weeklyProgress = "weekly_progress"
    }
}
