import SwiftUI

@main
struct EMOpsApp: App {
    @StateObject private var authService = AuthService.shared
    @StateObject private var syncService = SyncService.shared

    init() {
        configureAppearance()
        setupNotifications()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(syncService)
                .preferredColorScheme(.dark)
        }
    }

    // MARK: - Configuration

    private func configureAppearance() {
        // Navigation bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(Color(hex: "0F1117"))
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color(hex: "E8ECF4"))
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color(hex: "E8ECF4"))
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance

        // Tab bar (hidden, but configure just in case)
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(Color(hex: "1A1D27"))
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }

    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = NotificationService.shared
    }
}
