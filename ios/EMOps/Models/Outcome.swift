import Foundation

struct Outcome: Codable, Identifiable, Equatable {
    let id: String
    let sheetId: String
    let position: Int
    let outcomeText: String
    let impact: String
    let definitionOfDone: String
    let owner: String
    let riskAndMitigation: String
    let status: OutcomeStatus
    let completedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case sheetId = "sheet_id"
        case position
        case outcomeText = "outcome_text"
        case impact
        case definitionOfDone = "definition_of_done"
        case owner
        case riskAndMitigation = "risk_and_mitigation"
        case status
        case completedAt = "completed_at"
    }

    enum OutcomeStatus: String, Codable, CaseIterable {
        case inProgress = "in_progress"
        case done
        case blocked
        case carriedOver = "carried_over"
    }
}
