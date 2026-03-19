import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var dashboardData: DashboardData?
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    @Published var currentSheet: WeeklySheet?
    @Published var dsaaStreak: Int = 0
    @Published var todayHabitsCompleted: Int = 0
    @Published var todayHabitsTotal: Int = 0
    @Published var aiCoachingNote: String?
    @Published var upcomingReminders: [Reminder] = []

    private let api = APIService.shared
    private let syncService = SyncService.shared

    func loadDashboard() async {
        isLoading = true
        errorMessage = nil

        do {
            let data: DashboardData = try await api.getDashboardData()
            dashboardData = data
            currentSheet = data.currentSheet
            dsaaStreak = data.dsaaStreak
            todayHabitsCompleted = data.todayHabits.completed
            todayHabitsTotal = data.todayHabits.total
            aiCoachingNote = data.aiCoachingNote
            upcomingReminders = data.upcomingReminders
        } catch {
            self.errorMessage = error.localizedDescription

            // Fall back to cached data
            if let cachedSheet = syncService.getCachedSheetIfOffline() {
                currentSheet = cachedSheet
            }
        }

        isLoading = false
    }

    func refreshData() async {
        await loadDashboard()
    }

    func retry() {
        Task { await loadDashboard() }
    }
}
