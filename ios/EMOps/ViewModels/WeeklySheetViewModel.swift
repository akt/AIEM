import Foundation
import Combine

@MainActor
class WeeklySheetViewModel: ObservableObject {
    @Published var sheet: WeeklySheet?
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var selectedTab: Int = 0
    @Published var outcomes: [Outcome] = []
    @Published var decisions: [LeadershipDecision] = []

    private let api = APIService.shared

    // MARK: - Sheet Loading

    func loadCurrentSheet() async {
        isLoading = true
        error = nil

        do {
            let currentSheet = try await api.getCurrentSheet()
            sheet = currentSheet
            outcomes = currentSheet.outcomes
            decisions = currentSheet.decisions
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func loadSheet(id: String) async {
        isLoading = true
        error = nil

        do {
            let loadedSheet = try await api.getSheet(id: id)
            sheet = loadedSheet
            outcomes = loadedSheet.outcomes
            decisions = loadedSheet.decisions
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func updateSheet() async {
        guard let sheet = sheet else { return }
        error = nil

        do {
            let updated: WeeklySheet = try await api.updateSheet(id: sheet.id, body: sheet)
            self.sheet = updated
            outcomes = updated.outcomes
            decisions = updated.decisions
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Outcomes

    func addOutcome(text: String, impact: String, dod: String, owner: String, risk: String) async {
        guard let sheet = sheet else { return }
        error = nil

        let body = CreateOutcomeBody(
            outcomeText: text,
            impact: impact,
            definitionOfDone: dod,
            owner: owner,
            riskAndMitigation: risk
        )

        do {
            let outcome = try await api.createOutcome(sheetId: sheet.id, body: body)
            outcomes.append(outcome)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func updateOutcomeStatus(id: String, status: Outcome.OutcomeStatus) async {
        guard let sheet = sheet else { return }
        error = nil

        do {
            let updated = try await api.updateOutcomeStatus(sheetId: sheet.id, outcomeId: id, status: status)
            if let index = outcomes.firstIndex(where: { $0.id == id }) {
                outcomes[index] = updated
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func deleteOutcome(id: String) async {
        guard let sheet = sheet else { return }
        error = nil

        do {
            try await api.deleteOutcome(sheetId: sheet.id, outcomeId: id)
            outcomes.removeAll { $0.id == id }
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Section Updates

    func updateConstraint() async {
        guard let sheet = sheet else { return }
        error = nil

        let body = ConstraintUpdateBody(
            constraintStatement: sheet.constraintStatement,
            constraintEvidence: sheet.constraintEvidence,
            constraintSloService: sheet.constraintSloService,
            constraintSloTargets: sheet.constraintSloTargets,
            constraintErrorBudgetStatus: sheet.constraintErrorBudgetStatus,
            constraintExhaustedAction: sheet.constraintExhaustedAction
        )

        do {
            let updated = try await api.updateConstraint(sheetId: sheet.id, body: body)
            self.sheet = updated
        } catch {
            self.error = error.localizedDescription
        }
    }

    func updateDsaaQueue() async {
        guard let sheet = sheet else { return }
        error = nil

        let body = DsaaQueueUpdateBody(
            dsaaQueue: sheet.dsaaQueue,
            dsaaFocusThisWeek: sheet.dsaaFocusThisWeek
        )

        do {
            let updated = try await api.updateDsaaQueue(sheetId: sheet.id, body: body)
            self.sheet = updated
        } catch {
            self.error = error.localizedDescription
        }
    }

    func updateAiPlan() async {
        guard let sheet = sheet else { return }
        error = nil

        let body = AiPlanUpdateBody(
            aiTasks: sheet.aiTasks,
            aiGuardrailsChecked: sheet.aiGuardrailsChecked
        )

        do {
            let updated = try await api.updateAiPlan(sheetId: sheet.id, body: body)
            self.sheet = updated
        } catch {
            self.error = error.localizedDescription
        }
    }

    func updateTimeBlocks() async {
        guard let sheet = sheet else { return }
        error = nil

        let body = TimeBlocksUpdateBody(timeBlocks: sheet.timeBlocks)

        do {
            let updated = try await api.updateTimeBlocks(sheetId: sheet.id, body: body)
            self.sheet = updated
        } catch {
            self.error = error.localizedDescription
        }
    }

    func updateIncidentChecklist() async {
        guard let sheet = sheet else { return }
        error = nil

        let body = IncidentChecklistUpdateBody(incidentChecklist: sheet.incidentChecklist)

        do {
            let updated = try await api.updateIncidentChecklist(sheetId: sheet.id, body: body)
            self.sheet = updated
        } catch {
            self.error = error.localizedDescription
        }
    }

    func updateAdrChecklist() async {
        guard let sheet = sheet else { return }
        error = nil

        let body = AdrChecklistUpdateBody(adrChecklist: sheet.adrChecklist)

        do {
            let updated = try await api.updateAdrChecklist(sheetId: sheet.id, body: body)
            self.sheet = updated
        } catch {
            self.error = error.localizedDescription
        }
    }

    func updateScorecard() async {
        guard let sheet = sheet, let scorecard = sheet.scorecard else { return }
        error = nil

        let body = ScorecardUpdateBody(scorecard: scorecard)

        do {
            let updated = try await api.updateScorecard(sheetId: sheet.id, body: body)
            self.sheet = updated
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Sheet Lifecycle

    func completeSheet() async {
        guard let sheet = sheet else { return }
        isLoading = true
        error = nil

        do {
            let updated = try await api.completeSheet(sheetId: sheet.id)
            self.sheet = updated
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func carryForward() async {
        guard let sheet = sheet else { return }
        isLoading = true
        error = nil

        do {
            let newSheet = try await api.carryForward(sheetId: sheet.id)
            self.sheet = newSheet
            outcomes = newSheet.outcomes
            decisions = newSheet.decisions
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func generateSummary() async {
        guard let sheet = sheet else { return }
        isLoading = true
        error = nil

        do {
            let response = try await api.getWeeklySummary(sheetId: sheet.id)
            // Reload sheet to pick up AI summary stored server-side
            let refreshed = try await api.getSheet(id: sheet.id)
            self.sheet = refreshed
            _ = response.text
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}

// MARK: - Request Bodies

private struct CreateOutcomeBody: Encodable {
    let outcomeText: String
    let impact: String
    let definitionOfDone: String
    let owner: String
    let riskAndMitigation: String

    enum CodingKeys: String, CodingKey {
        case outcomeText = "outcome_text"
        case impact
        case definitionOfDone = "definition_of_done"
        case owner
        case riskAndMitigation = "risk_and_mitigation"
    }
}

private struct ConstraintUpdateBody: Encodable {
    let constraintStatement: String
    let constraintEvidence: ConstraintEvidence
    let constraintSloService: String
    let constraintSloTargets: String
    let constraintErrorBudgetStatus: WeeklySheet.ErrorBudgetStatus
    let constraintExhaustedAction: String

    enum CodingKeys: String, CodingKey {
        case constraintStatement = "constraint_statement"
        case constraintEvidence = "constraint_evidence"
        case constraintSloService = "constraint_slo_service"
        case constraintSloTargets = "constraint_slo_targets"
        case constraintErrorBudgetStatus = "constraint_error_budget_status"
        case constraintExhaustedAction = "constraint_exhausted_action"
    }
}

private struct DsaaQueueUpdateBody: Encodable {
    let dsaaQueue: DsaaQueue
    let dsaaFocusThisWeek: WeeklySheet.DsaaFocus

    enum CodingKeys: String, CodingKey {
        case dsaaQueue = "dsaa_queue"
        case dsaaFocusThisWeek = "dsaa_focus_this_week"
    }
}

private struct AiPlanUpdateBody: Encodable {
    let aiTasks: [AiTask]
    let aiGuardrailsChecked: [String]

    enum CodingKeys: String, CodingKey {
        case aiTasks = "ai_tasks"
        case aiGuardrailsChecked = "ai_guardrails_checked"
    }
}

private struct TimeBlocksUpdateBody: Encodable {
    let timeBlocks: [String: DayTimeBlock]

    enum CodingKeys: String, CodingKey {
        case timeBlocks = "time_blocks"
    }
}

private struct IncidentChecklistUpdateBody: Encodable {
    let incidentChecklist: IncidentChecklist

    enum CodingKeys: String, CodingKey {
        case incidentChecklist = "incident_checklist"
    }
}

private struct AdrChecklistUpdateBody: Encodable {
    let adrChecklist: AdrChecklist

    enum CodingKeys: String, CodingKey {
        case adrChecklist = "adr_checklist"
    }
}

private struct ScorecardUpdateBody: Encodable {
    let scorecard: WeeklyScorecard

    enum CodingKeys: String, CodingKey {
        case scorecard
    }
}
