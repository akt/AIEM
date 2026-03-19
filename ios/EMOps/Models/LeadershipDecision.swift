import Foundation

struct LeadershipDecision: Codable, Identifiable, Equatable {
    let id: String
    let sheetId: String
    let position: Int
    let decisionText: String
    let byWhen: String
    let inputsNeeded: String
    let status: DecisionStatus
    let decisionResult: String?

    enum CodingKeys: String, CodingKey {
        case id
        case sheetId = "sheet_id"
        case position
        case decisionText = "decision_text"
        case byWhen = "by_when"
        case inputsNeeded = "inputs_needed"
        case status
        case decisionResult = "decision_result"
    }

    enum DecisionStatus: String, Codable, CaseIterable {
        case pending
        case decided
        case deferred
    }
}
