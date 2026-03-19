import Foundation

struct LoginRequest: Codable, Equatable {
    let email: String
    let password: String

    enum CodingKeys: String, CodingKey {
        case email
        case password
    }
}

struct RegisterRequest: Codable, Equatable {
    let email: String
    let password: String
    let displayName: String

    enum CodingKeys: String, CodingKey {
        case email
        case password
        case displayName = "display_name"
    }
}

struct TokenPair: Codable, Equatable {
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct AuthResponse: Codable, Equatable {
    let user: User
    let tokens: TokenPair

    enum CodingKeys: String, CodingKey {
        case user
        case tokens
    }
}
