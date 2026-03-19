import Foundation
import Combine

enum TrendPeriod: String, CaseIterable {
    case week
    case month
    case quarter

    var weekCount: Int {
        switch self {
        case .week: return 4
        case .month: return 8
        case .quarter: return 13
        }
    }
}

@MainActor
class TrendsViewModel: ObservableObject {
    @Published var weeklyTrends: [TrendData] = []
    @Published var habitTrends: HabitTrendResponse?
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var selectedPeriod: TrendPeriod = .week
    @Published var aiTrendInsight: String?

    private let api = APIService.shared

    // MARK: - Loading

    func loadTrends() async {
        isLoading = true
        error = nil

        do {
            weeklyTrends = try await api.getWeeklyTrends(weeks: selectedPeriod.weekCount)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func loadHabitTrends() async {
        error = nil

        do {
            habitTrends = try await api.getHabitTrends(weeks: selectedPeriod.weekCount)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadDsaaTrends() async {
        error = nil

        do {
            let _ = try await api.getDsaaTrends(weeks: selectedPeriod.weekCount)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadDeepWorkTrends() async {
        error = nil

        do {
            let _ = try await api.getDeepWorkTrends(weeks: selectedPeriod.weekCount)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func requestAiInsight() async {
        error = nil

        do {
            let response = try await api.getTrendInsight()
            aiTrendInsight = response.text
        } catch {
            self.error = error.localizedDescription
        }
    }
}
