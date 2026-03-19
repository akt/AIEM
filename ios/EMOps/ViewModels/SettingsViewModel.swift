import Foundation
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var notificationPermissionGranted: Bool = false

    private let api = APIService.shared
    private let authService = AuthService.shared
    private let notificationService = NotificationService.shared

    // MARK: - Loading

    func loadUser() async {
        isLoading = true
        error = nil

        do {
            let currentUser: User = try await api.get(endpoint: "/auth/me")
            user = currentUser
            notificationPermissionGranted = notificationService.isPermissionGranted
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Profile

    func updateProfile() async {
        guard let user = user else { return }
        error = nil
        isLoading = true

        let body = UpdateProfileBody(
            displayName: user.displayName,
            timezone: user.timezone,
            role: user.role,
            surfaces: user.surfaces,
            dsaaTriggerTime: user.dsaaTriggerTime,
            dsaaTriggerEvent: user.dsaaTriggerEvent,
            deepWorkHoursTarget: user.deepWorkHoursTarget
        )

        do {
            let updated: User = try await api.put(endpoint: "/auth/me", body: body)
            self.user = updated
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Notifications

    func updateNotificationPreferences() async {
        guard let user = user else { return }
        error = nil

        let body = NotificationPreferencesBody(
            notificationPreferences: user.notificationPreferences
        )

        do {
            let updated: User = try await api.put(endpoint: "/auth/me", body: body)
            self.user = updated
        } catch {
            self.error = error.localizedDescription
        }
    }

    func requestNotificationPermission() async {
        let granted = await notificationService.requestPermission()
        notificationPermissionGranted = granted
    }

    // MARK: - Auth

    func logout() {
        authService.logout()
    }
}

// MARK: - Request Bodies

private struct UpdateProfileBody: Encodable {
    let displayName: String
    let timezone: String
    let role: String
    let surfaces: [String]
    let dsaaTriggerTime: String
    let dsaaTriggerEvent: String
    let deepWorkHoursTarget: Double

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case timezone
        case role
        case surfaces
        case dsaaTriggerTime = "dsaa_trigger_time"
        case dsaaTriggerEvent = "dsaa_trigger_event"
        case deepWorkHoursTarget = "deep_work_hours_target"
    }
}

private struct NotificationPreferencesBody: Encodable {
    let notificationPreferences: NotificationPreferences

    enum CodingKeys: String, CodingKey {
        case notificationPreferences = "notification_preferences"
    }
}
