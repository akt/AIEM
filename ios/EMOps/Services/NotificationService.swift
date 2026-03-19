import Foundation
import UserNotifications
import Combine

final class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    @Published var isPermissionGranted: Bool = false

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            await MainActor.run {
                self.isPermissionGranted = granted
            }
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }

    // MARK: - Push Notifications

    func registerForPushNotifications() {
        Task {
            let granted = await requestPermission()
            if granted {
                await MainActor.run {
                    #if !targetEnvironment(simulator)
                    UIApplication.shared.registerForRemoteNotifications()
                    #endif
                }
            }
        }
    }

    // MARK: - Local Notifications

    func scheduleLocalNotification(title: String, body: String, date: Date, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        handleNotificationAction(userInfo: userInfo)
        completionHandler()
    }

    // MARK: - Notification Handling

    private func handleNotificationAction(userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String else { return }

        NotificationCenter.default.post(
            name: .emopsNotificationReceived,
            object: nil,
            userInfo: ["type": type, "data": userInfo]
        )
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let emopsNotificationReceived = Notification.Name("emopsNotificationReceived")
}
