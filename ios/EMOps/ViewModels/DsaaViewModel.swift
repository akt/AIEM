import Foundation
import Combine

@MainActor
class DsaaViewModel: ObservableObject {
    @Published var todayLog: DsaaLog?
    @Published var aiSuggestion: AiSuggestionResponse?
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var isTimerRunning: Bool = false
    @Published var timerSecondsRemaining: Int = 900
    @Published var history: [DsaaLog] = []
    @Published var frictionPoint: String = ""
    @Published var selectedAction: DsaaLog.DsaaAction = .simplify
    @Published var microArtifactType: String = ""
    @Published var microArtifactDescription: String = ""
    @Published var expectedLeverage: String = ""

    private let api = APIService.shared
    private var timerCancellable: AnyCancellable?

    // MARK: - Loading

    func loadToday() async {
        isLoading = true
        error = nil

        do {
            todayLog = try await api.getTodayDsaa()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func loadHistory() async {
        error = nil

        do {
            history = try await api.getDsaaHistory()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func fetchAiSuggestion() async {
        error = nil

        do {
            aiSuggestion = try await api.getAiSuggestion()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func acceptSuggestion() {
        guard let suggestion = aiSuggestion else { return }
        frictionPoint = suggestion.suggestion
        if let action = DsaaLog.DsaaAction(rawValue: suggestion.suggestedAction) {
            selectedAction = action
        }
    }

    // MARK: - Timer

    func startTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true
        timerSecondsRemaining = 900

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timerSecondsRemaining > 0 {
                    self.timerSecondsRemaining -= 1
                } else {
                    self.stopTimer()
                }
            }
    }

    func stopTimer() {
        isTimerRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    // MARK: - Save

    func saveDsaaLog() async {
        error = nil
        isLoading = true

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())

        let durationMinutes = (900 - timerSecondsRemaining) / 60

        let body = CreateDsaaLogBody(
            logDate: today,
            frictionPoint: frictionPoint,
            dsaaAction: selectedAction,
            microArtifactType: microArtifactType,
            microArtifactDescription: microArtifactDescription,
            expectedLeverage: expectedLeverage,
            durationMinutes: durationMinutes,
            aiSuggestedAction: aiSuggestion?.suggestedAction,
            aiSuggestionAccepted: aiSuggestion != nil
        )

        do {
            let log = try await api.logDsaa(body: body)
            todayLog = log
            stopTimer()
            // Reset form fields
            frictionPoint = ""
            microArtifactType = ""
            microArtifactDescription = ""
            expectedLeverage = ""
            aiSuggestion = nil
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}

// MARK: - Request Body

private struct CreateDsaaLogBody: Encodable {
    let logDate: String
    let frictionPoint: String
    let dsaaAction: DsaaLog.DsaaAction
    let microArtifactType: String
    let microArtifactDescription: String
    let expectedLeverage: String
    let durationMinutes: Int
    let aiSuggestedAction: String?
    let aiSuggestionAccepted: Bool

    enum CodingKeys: String, CodingKey {
        case logDate = "log_date"
        case frictionPoint = "friction_point"
        case dsaaAction = "dsaa_action"
        case microArtifactType = "micro_artifact_type"
        case microArtifactDescription = "micro_artifact_description"
        case expectedLeverage = "expected_leverage"
        case durationMinutes = "duration_minutes"
        case aiSuggestedAction = "ai_suggested_action"
        case aiSuggestionAccepted = "ai_suggestion_accepted"
    }
}
