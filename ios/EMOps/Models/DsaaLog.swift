import Foundation

struct DsaaLog: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let sheetId: String?
    let logDate: String
    let frictionPoint: String
    let dsaaAction: DsaaAction
    let microArtifactType: String
    let microArtifactDescription: String
    let expectedLeverage: String
    let startedAt: String?
    let completedAt: String?
    let durationMinutes: Int?
    let aiSuggestedAction: String?
    let aiSuggestionAccepted: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case sheetId = "sheet_id"
        case logDate = "log_date"
        case frictionPoint = "friction_point"
        case dsaaAction = "dsaa_action"
        case microArtifactType = "micro_artifact_type"
        case microArtifactDescription = "micro_artifact_description"
        case expectedLeverage = "expected_leverage"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case durationMinutes = "duration_minutes"
        case aiSuggestedAction = "ai_suggested_action"
        case aiSuggestionAccepted = "ai_suggestion_accepted"
    }

    enum DsaaAction: String, Codable, CaseIterable {
        case delete
        case simplify
        case accelerate
        case automate
    }
}
