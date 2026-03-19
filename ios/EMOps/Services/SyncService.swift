import Foundation
import Combine

final class SyncService: ObservableObject {
    static let shared = SyncService()

    @Published var isSyncing: Bool = false
    @Published var lastSyncDate: Date?
    @Published var syncError: Error?

    private let api = APIService.shared
    private let persistence = PersistenceController.shared

    private init() {}

    // MARK: - Full Sync

    func syncAll() async {
        guard !isSyncing else { return }

        await MainActor.run {
            self.isSyncing = true
            self.syncError = nil
        }

        defer {
            Task { @MainActor in
                self.isSyncing = false
            }
        }

        await syncCurrentSheet()
        await syncHabits()
        await syncHabitLogs()

        await MainActor.run {
            self.lastSyncDate = Date()
        }
    }

    // MARK: - Individual Syncs

    private func syncCurrentSheet() async {
        do {
            let sheet = try await api.getCurrentSheet()
            persistence.cacheWeeklySheet(sheet)
        } catch {
            await MainActor.run {
                self.syncError = error
            }
            print("SyncService: Failed to sync current sheet: \(error)")
        }
    }

    private func syncHabits() async {
        do {
            let habits = try await api.getHabits()
            persistence.cacheHabits(habits)
        } catch {
            await MainActor.run {
                self.syncError = error
            }
            print("SyncService: Failed to sync habits: \(error)")
        }
    }

    private func syncHabitLogs() async {
        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let today = formatter.string(from: Date())
            let _ = try await api.getHabitLogs(date: today)
            // Habit logs are transient; fetched for freshness but not cached long-term
        } catch {
            print("SyncService: Failed to sync habit logs: \(error)")
        }
    }

    // MARK: - Offline Fallbacks

    func getCachedSheetIfOffline() -> WeeklySheet? {
        return persistence.getCachedSheet()
    }

    func getCachedHabitsIfOffline() -> [Habit] {
        return persistence.getCachedHabits()
    }
}
