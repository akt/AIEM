import Foundation
import Combine

@MainActor
class AiCoachViewModel: ObservableObject {
    @Published var dailyCoaching: String?
    @Published var weeklyInsight: String?
    @Published var constraintAnalysis: String?
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var messages: [CoachMessage] = []

    private let api = APIService.shared

    struct CoachMessage: Identifiable {
        let id: UUID
        let content: String
        let isFromAi: Bool
        let timestamp: Date

        init(id: UUID = UUID(), content: String, isFromAi: Bool, timestamp: Date = Date()) {
            self.id = id
            self.content = content
            self.isFromAi = isFromAi
            self.timestamp = timestamp
        }
    }

    // MARK: - Loading

    func loadDailyCoaching() async {
        isLoading = true
        error = nil

        do {
            let response = try await api.getDailyCoaching()
            dailyCoaching = response.text
            messages.append(CoachMessage(content: response.text, isFromAi: true))
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func getWeeklySummary() async {
        isLoading = true
        error = nil

        do {
            let currentSheet = try await api.getCurrentSheet()
            let response = try await api.getWeeklySummary(sheetId: currentSheet.id)
            weeklyInsight = response.text
            messages.append(CoachMessage(content: response.text, isFromAi: true))
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func analyzeConstraint() async {
        isLoading = true
        error = nil

        do {
            let currentSheet = try await api.getCurrentSheet()
            let response = try await api.getConstraintAnalysis(sheetId: currentSheet.id)
            constraintAnalysis = response.text
            messages.append(CoachMessage(content: response.text, isFromAi: true))
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func getTrendInsight() async {
        isLoading = true
        error = nil

        do {
            let response = try await api.getTrendInsight()
            messages.append(CoachMessage(content: response.text, isFromAi: true))
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func sendMessage(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        error = nil

        messages.append(CoachMessage(content: text, isFromAi: false))

        isLoading = true

        do {
            let response = try await api.getDailyCoaching()
            messages.append(CoachMessage(content: response.text, isFromAi: true))
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
