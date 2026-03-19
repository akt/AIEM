import Foundation
import Combine
import Security

final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?

    private let accessTokenKey = "com.emops.accessToken"
    private let refreshTokenKey = "com.emops.refreshToken"

    private init() {
        loadTokens()
    }

    // MARK: - Public Methods

    func login(email: String, password: String) async throws {
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await APIService.shared.post(
            endpoint: "/auth/login",
            body: request
        )
        saveTokens(response.tokens)
        await MainActor.run {
            self.currentUser = response.user
            self.isAuthenticated = true
        }
    }

    func register(email: String, password: String, displayName: String) async throws {
        let request = RegisterRequest(email: email, password: password, displayName: displayName)
        let response: AuthResponse = try await APIService.shared.post(
            endpoint: "/auth/register",
            body: request
        )
        saveTokens(response.tokens)
        await MainActor.run {
            self.currentUser = response.user
            self.isAuthenticated = true
        }
    }

    func refreshToken() async throws {
        guard let currentRefreshToken = getRefreshToken() else {
            throw AuthError.noRefreshToken
        }
        let body = RefreshTokenRequest(refreshToken: currentRefreshToken)
        let response: TokenPair = try await APIService.shared.post(
            endpoint: "/auth/refresh",
            body: body
        )
        saveTokens(response)
    }

    func logout() {
        deleteFromKeychain(key: accessTokenKey)
        deleteFromKeychain(key: refreshTokenKey)
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }

    func getAccessToken() -> String? {
        return readFromKeychain(key: accessTokenKey)
    }

    // MARK: - Token Persistence

    func saveTokens(_ tokens: TokenPair) {
        saveToKeychain(key: accessTokenKey, value: tokens.accessToken)
        saveToKeychain(key: refreshTokenKey, value: tokens.refreshToken)
    }

    func loadTokens() {
        let hasAccess = readFromKeychain(key: accessTokenKey) != nil
        let hasRefresh = readFromKeychain(key: refreshTokenKey) != nil
        isAuthenticated = hasAccess && hasRefresh
    }

    // MARK: - Keychain Helpers

    private func getRefreshToken() -> String? {
        return readFromKeychain(key: refreshTokenKey)
    }

    private func saveToKeychain(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        // Delete existing item first
        deleteFromKeychain(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    private func readFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Errors

    enum AuthError: LocalizedError {
        case noRefreshToken
        case invalidCredentials
        case tokenExpired

        var errorDescription: String? {
            switch self {
            case .noRefreshToken:
                return "No refresh token available. Please log in again."
            case .invalidCredentials:
                return "Invalid email or password."
            case .tokenExpired:
                return "Session expired. Please log in again."
            }
        }
    }
}

// MARK: - Supporting Types

private struct RefreshTokenRequest: Codable {
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}
