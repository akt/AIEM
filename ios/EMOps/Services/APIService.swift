import Foundation
import Combine

final class APIService {
    static let shared = APIService()

    var baseURL: String = "http://localhost:3000/api"

    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        session = URLSession(configuration: config)

        encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    // MARK: - Generic HTTP Methods

    func get<T: Decodable>(endpoint: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, method: "GET", queryItems: queryItems)
        return try await execute(request)
    }

    func post<T: Decodable, B: Encodable>(endpoint: String, body: B) async throws -> T {
        var request = try buildRequest(endpoint: endpoint, method: "POST")
        request.httpBody = try encoder.encode(body)
        return try await execute(request)
    }

    func post(endpoint: String) async throws {
        let request = try buildRequest(endpoint: endpoint, method: "POST")
        try await executeVoid(request)
    }

    func put<T: Decodable, B: Encodable>(endpoint: String, body: B) async throws -> T {
        var request = try buildRequest(endpoint: endpoint, method: "PUT")
        request.httpBody = try encoder.encode(body)
        return try await execute(request)
    }

    func delete(endpoint: String) async throws {
        let request = try buildRequest(endpoint: endpoint, method: "DELETE")
        try await executeVoid(request)
    }

    // MARK: - Request Builder

    private func buildRequest(
        endpoint: String,
        method: String,
        queryItems: [URLQueryItem]? = nil
    ) throws -> URLRequest {
        guard var components = URLComponents(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        if let queryItems = queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = AuthService.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    // MARK: - Execution with 401 Retry

    private func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            return try await performRequest(request)
        } catch APIError.unauthorized {
            try await AuthService.shared.refreshToken()
            var retryRequest = request
            if let token = AuthService.shared.getAccessToken() {
                retryRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            return try await performRequest(retryRequest)
        }
    }

    private func executeVoid(_ request: URLRequest) async throws {
        do {
            try await performVoidRequest(request)
        } catch APIError.unauthorized {
            try await AuthService.shared.refreshToken()
            var retryRequest = request
            if let token = AuthService.shared.getAccessToken() {
                retryRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            try await performVoidRequest(retryRequest)
        }
    }

    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return try decoder.decode(T.self, from: data)
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 422:
            let errorBody = try? decoder.decode(ValidationErrorResponse.self, from: data)
            throw APIError.validationError(errorBody?.message ?? "Validation failed")
        default:
            let errorBody = try? decoder.decode(ErrorResponse.self, from: data)
            throw APIError.serverError(
                statusCode: httpResponse.statusCode,
                message: errorBody?.message ?? "Unknown error"
            )
        }
    }

    private func performVoidRequest(_ request: URLRequest) async throws {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 422:
            let errorBody = try? decoder.decode(ValidationErrorResponse.self, from: data)
            throw APIError.validationError(errorBody?.message ?? "Validation failed")
        default:
            let errorBody = try? decoder.decode(ErrorResponse.self, from: data)
            throw APIError.serverError(
                statusCode: httpResponse.statusCode,
                message: errorBody?.message ?? "Unknown error"
            )
        }
    }

    // MARK: - Auth Endpoints

    func login(email: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(email: email, password: password)
        return try await post(endpoint: "/auth/login", body: body)
    }

    func register(email: String, password: String, displayName: String) async throws -> AuthResponse {
        let body = RegisterRequest(email: email, password: password, displayName: displayName)
        return try await post(endpoint: "/auth/register", body: body)
    }

    func refreshToken(token: String) async throws -> TokenPair {
        let body = RefreshRequest(refreshToken: token)
        return try await post(endpoint: "/auth/refresh", body: body)
    }

    // MARK: - Weekly Sheets

    func getCurrentSheet() async throws -> WeeklySheet {
        return try await get(endpoint: "/sheets/current")
    }

    func getSheet(id: String) async throws -> WeeklySheet {
        return try await get(endpoint: "/sheets/\(id)")
    }

    func listSheets() async throws -> [WeeklySheet] {
        return try await get(endpoint: "/sheets")
    }

    func updateSheet(id: String, body: some Encodable) async throws -> WeeklySheet {
        return try await put(endpoint: "/sheets/\(id)", body: body)
    }

    func updateConstraint(sheetId: String, body: some Encodable) async throws -> WeeklySheet {
        return try await put(endpoint: "/sheets/\(sheetId)/constraint", body: body)
    }

    func updateDsaaQueue(sheetId: String, body: some Encodable) async throws -> WeeklySheet {
        return try await put(endpoint: "/sheets/\(sheetId)/dsaa-queue", body: body)
    }

    func updateAiPlan(sheetId: String, body: some Encodable) async throws -> WeeklySheet {
        return try await put(endpoint: "/sheets/\(sheetId)/ai-plan", body: body)
    }

    func updateTimeBlocks(sheetId: String, body: some Encodable) async throws -> WeeklySheet {
        return try await put(endpoint: "/sheets/\(sheetId)/time-blocks", body: body)
    }

    func updateIncidentChecklist(sheetId: String, body: some Encodable) async throws -> WeeklySheet {
        return try await put(endpoint: "/sheets/\(sheetId)/incident-checklist", body: body)
    }

    func updateAdrChecklist(sheetId: String, body: some Encodable) async throws -> WeeklySheet {
        return try await put(endpoint: "/sheets/\(sheetId)/adr-checklist", body: body)
    }

    func updateScorecard(sheetId: String, body: some Encodable) async throws -> WeeklySheet {
        return try await put(endpoint: "/sheets/\(sheetId)/scorecard", body: body)
    }

    func completeSheet(sheetId: String) async throws -> WeeklySheet {
        let empty = EmptyBody()
        return try await post(endpoint: "/sheets/\(sheetId)/complete", body: empty)
    }

    func carryForward(sheetId: String) async throws -> WeeklySheet {
        let empty = EmptyBody()
        return try await post(endpoint: "/sheets/\(sheetId)/carry-forward", body: empty)
    }

    // MARK: - Outcomes

    func getOutcomes(sheetId: String) async throws -> [Outcome] {
        return try await get(endpoint: "/sheets/\(sheetId)/outcomes")
    }

    func createOutcome(sheetId: String, body: some Encodable) async throws -> Outcome {
        return try await post(endpoint: "/sheets/\(sheetId)/outcomes", body: body)
    }

    func updateOutcome(sheetId: String, outcomeId: String, body: some Encodable) async throws -> Outcome {
        return try await put(endpoint: "/sheets/\(sheetId)/outcomes/\(outcomeId)", body: body)
    }

    func deleteOutcome(sheetId: String, outcomeId: String) async throws {
        try await delete(endpoint: "/sheets/\(sheetId)/outcomes/\(outcomeId)")
    }

    func updateOutcomeStatus(sheetId: String, outcomeId: String, status: Outcome.OutcomeStatus) async throws -> Outcome {
        let body = OutcomeStatusUpdate(status: status)
        return try await put(endpoint: "/sheets/\(sheetId)/outcomes/\(outcomeId)/status", body: body)
    }

    // MARK: - Habits

    func getHabits() async throws -> [Habit] {
        return try await get(endpoint: "/habits")
    }

    func createHabit(body: some Encodable) async throws -> Habit {
        return try await post(endpoint: "/habits", body: body)
    }

    func updateHabit(id: String, body: some Encodable) async throws -> Habit {
        return try await put(endpoint: "/habits/\(id)", body: body)
    }

    func deleteHabit(id: String) async throws {
        try await delete(endpoint: "/habits/\(id)")
    }

    // MARK: - Habit Logs

    func getHabitLogs(date: String) async throws -> [HabitLog] {
        let queryItems = [URLQueryItem(name: "date", value: date)]
        return try await get(endpoint: "/habits/logs", queryItems: queryItems)
    }

    func logHabit(body: some Encodable) async throws -> HabitLog {
        return try await post(endpoint: "/habits/logs", body: body)
    }

    func bulkLogHabits(body: some Encodable) async throws -> [HabitLog] {
        return try await post(endpoint: "/habits/logs/bulk", body: body)
    }

    // MARK: - DSAA

    func getTodayDsaa() async throws -> DsaaLog? {
        return try await get(endpoint: "/dsaa/today")
    }

    func logDsaa(body: some Encodable) async throws -> DsaaLog {
        return try await post(endpoint: "/dsaa", body: body)
    }

    func getDsaaHistory(limit: Int = 30) async throws -> [DsaaLog] {
        let queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        return try await get(endpoint: "/dsaa/history", queryItems: queryItems)
    }

    func getDsaaStats() async throws -> DsaaStatsResponse {
        return try await get(endpoint: "/dsaa/stats")
    }

    func getAiSuggestion() async throws -> AiSuggestionResponse {
        return try await get(endpoint: "/dsaa/ai-suggestion")
    }

    // MARK: - Trends

    func getWeeklyTrends(weeks: Int = 8) async throws -> [TrendData] {
        let queryItems = [URLQueryItem(name: "weeks", value: String(weeks))]
        return try await get(endpoint: "/trends/weekly", queryItems: queryItems)
    }

    func getHabitTrends(weeks: Int = 8) async throws -> HabitTrendResponse {
        let queryItems = [URLQueryItem(name: "weeks", value: String(weeks))]
        return try await get(endpoint: "/trends/habits", queryItems: queryItems)
    }

    func getDsaaTrends(weeks: Int = 8) async throws -> DsaaTrendResponse {
        let queryItems = [URLQueryItem(name: "weeks", value: String(weeks))]
        return try await get(endpoint: "/trends/dsaa", queryItems: queryItems)
    }

    func getDeepWorkTrends(weeks: Int = 8) async throws -> DeepWorkTrendResponse {
        let queryItems = [URLQueryItem(name: "weeks", value: String(weeks))]
        return try await get(endpoint: "/trends/deep-work", queryItems: queryItems)
    }

    func getDashboardData() async throws -> DashboardData {
        return try await get(endpoint: "/trends/dashboard")
    }

    // MARK: - AI

    func getWeeklySummary(sheetId: String) async throws -> AiTextResponse {
        return try await get(endpoint: "/ai/weekly-summary/\(sheetId)")
    }

    func getDailyCoaching() async throws -> AiTextResponse {
        return try await get(endpoint: "/ai/daily-coaching")
    }

    func getConstraintAnalysis(sheetId: String) async throws -> AiTextResponse {
        return try await get(endpoint: "/ai/constraint-analysis/\(sheetId)")
    }

    func getTrendInsight() async throws -> AiTextResponse {
        return try await get(endpoint: "/ai/trend-insight")
    }

    // MARK: - Reminders

    func getReminders() async throws -> [Reminder] {
        return try await get(endpoint: "/reminders")
    }

    // MARK: - Error Types

    enum APIError: LocalizedError {
        case invalidURL
        case invalidResponse
        case unauthorized
        case notFound
        case validationError(String)
        case serverError(statusCode: Int, message: String)
        case decodingError(Error)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL."
            case .invalidResponse:
                return "Invalid server response."
            case .unauthorized:
                return "Authentication required."
            case .notFound:
                return "Resource not found."
            case .validationError(let message):
                return message
            case .serverError(_, let message):
                return message
            case .decodingError(let error):
                return "Failed to parse response: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Supporting Types

private struct EmptyBody: Encodable {}

private struct RefreshRequest: Encodable {
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

private struct OutcomeStatusUpdate: Encodable {
    let status: Outcome.OutcomeStatus
}

struct ErrorResponse: Decodable {
    let message: String
}

struct ValidationErrorResponse: Decodable {
    let message: String
    let errors: [String]?
}

struct DsaaStatsResponse: Codable {
    let totalLogs: Int
    let currentStreak: Int
    let bestStreak: Int
    let actionBreakdown: [String: Int]

    enum CodingKeys: String, CodingKey {
        case totalLogs = "total_logs"
        case currentStreak = "current_streak"
        case bestStreak = "best_streak"
        case actionBreakdown = "action_breakdown"
    }
}

struct AiSuggestionResponse: Codable {
    let suggestion: String
    let suggestedAction: String
    let reasoning: String

    enum CodingKeys: String, CodingKey {
        case suggestion
        case suggestedAction = "suggested_action"
        case reasoning
    }
}

struct HabitTrendResponse: Codable {
    let weeks: [HabitWeekTrend]
}

struct HabitWeekTrend: Codable {
    let weekStart: String
    let completionRate: Double
    let totalCompleted: Int
    let totalPossible: Int

    enum CodingKeys: String, CodingKey {
        case weekStart = "week_start"
        case completionRate = "completion_rate"
        case totalCompleted = "total_completed"
        case totalPossible = "total_possible"
    }
}

struct DsaaTrendResponse: Codable {
    let weeks: [DsaaWeekTrend]
}

struct DsaaWeekTrend: Codable {
    let weekStart: String
    let ritualsCompleted: Int
    let actionBreakdown: [String: Int]

    enum CodingKeys: String, CodingKey {
        case weekStart = "week_start"
        case ritualsCompleted = "rituals_completed"
        case actionBreakdown = "action_breakdown"
    }
}

struct DeepWorkTrendResponse: Codable {
    let weeks: [DeepWorkWeekTrend]
}

struct DeepWorkWeekTrend: Codable {
    let weekStart: String
    let hoursLogged: Double
    let hoursTarget: Double

    enum CodingKeys: String, CodingKey {
        case weekStart = "week_start"
        case hoursLogged = "hours_logged"
        case hoursTarget = "hours_target"
    }
}

struct AiTextResponse: Codable {
    let text: String
}
