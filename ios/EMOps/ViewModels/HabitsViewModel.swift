import Foundation
import Combine

@MainActor
class HabitsViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var habitLogs: [String: HabitLog] = [:]
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    @Published var selectedDate: Date = Date()
    @Published var completedCount: Int = 0
    @Published var totalCount: Int = 0
    @Published var currentStreak: Int = 0

    var groupedHabits: [HabitCategory: [Habit]] {
        Dictionary(grouping: habits, by: { $0.category })
    }

    private let api = APIService.shared
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // MARK: - Loading

    func loadHabits() async {
        isLoading = true
        errorMessage = nil

        do {
            habits = try await api.getHabits()
            await loadLogsForDate(selectedDate)
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func retry() {
        Task { await loadHabits() }
    }

    func loadLogsForDate(_ date: Date) async {
        let dateString = dateFormatter.string(from: date)
        errorMessage = nil

        do {
            let logs = try await api.getHabitLogs(date: dateString)
            var logMap: [String: HabitLog] = [:]
            for log in logs {
                logMap[log.habitId] = log
            }
            habitLogs = logMap
            updateCounts()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Habit Actions

    func toggleHabit(_ habit: Habit) async {
        errorMessage = nil
        let dateString = dateFormatter.string(from: selectedDate)

        let existingLog = habitLogs[habit.id]
        let newCompleted = !(existingLog?.isCompleted ?? false)

        let body = HabitLogBody(
            habitId: habit.id,
            logDate: dateString,
            value: newCompleted ? habit.targetValue : 0,
            isCompleted: newCompleted,
            notes: ""
        )

        do {
            let log: HabitLog = try await api.logHabit(body: body)
            habitLogs[habit.id] = log
            updateCounts()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func logHabitValue(_ habit: Habit, _ value: Double) async {
        errorMessage = nil
        let dateString = dateFormatter.string(from: selectedDate)
        let isCompleted = value >= habit.targetValue

        let body = HabitLogBody(
            habitId: habit.id,
            logDate: dateString,
            value: value,
            isCompleted: isCompleted,
            notes: ""
        )

        do {
            let log: HabitLog = try await api.logHabit(body: body)
            habitLogs[habit.id] = log
            updateCounts()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func createHabit(
        name: String,
        description: String,
        category: HabitCategory,
        frequency: Habit.Frequency,
        targetValue: Double,
        targetUnit: Habit.TargetUnit,
        reminderTime: String?,
        reminderEnabled: Bool
    ) async {
        errorMessage = nil

        let body = CreateHabitBody(
            name: name,
            description: description,
            category: category,
            frequency: frequency,
            targetValue: targetValue,
            targetUnit: targetUnit,
            reminderTime: reminderTime,
            reminderEnabled: reminderEnabled
        )

        do {
            let habit = try await api.createHabit(body: body)
            habits.append(habit)
            updateCounts()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func deleteHabit(id: String) async {
        errorMessage = nil

        do {
            try await api.deleteHabit(id: id)
            habits.removeAll { $0.id == id }
            habitLogs.removeValue(forKey: id)
            updateCounts()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private Helpers

    private func updateCounts() {
        let activeHabits = habits.filter { $0.isActive }
        totalCount = activeHabits.count
        completedCount = activeHabits.filter { habit in
            habitLogs[habit.id]?.isCompleted ?? false
        }.count
    }
}

// MARK: - Request Bodies

private struct HabitLogBody: Encodable {
    let habitId: String
    let logDate: String
    let value: Double
    let isCompleted: Bool
    let notes: String

    enum CodingKeys: String, CodingKey {
        case habitId = "habit_id"
        case logDate = "log_date"
        case value
        case isCompleted = "is_completed"
        case notes
    }
}

private struct CreateHabitBody: Encodable {
    let name: String
    let description: String
    let category: HabitCategory
    let frequency: Habit.Frequency
    let targetValue: Double
    let targetUnit: Habit.TargetUnit
    let reminderTime: String?
    let reminderEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case category
        case frequency
        case targetValue = "target_value"
        case targetUnit = "target_unit"
        case reminderTime = "reminder_time"
        case reminderEnabled = "reminder_enabled"
    }
}
