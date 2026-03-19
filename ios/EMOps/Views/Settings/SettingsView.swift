import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile section
                    profileSection

                    // Notification toggles
                    notificationsSection

                    // DSAA Settings
                    dsaaSettingsSection

                    // Deep Work
                    deepWorkSection

                    // Push Notifications Permission
                    pushPermissionSection

                    // App Info
                    appInfoSection

                    // Logout
                    Button(role: .destructive) {
                        viewModel.logout()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Log Out")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0xFF6B6B))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: 0xFF6B6B).opacity(0.12))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color(hex: 0x0F1117).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                }
            }
            .overlay {
                if viewModel.isLoading && viewModel.user == nil {
                    ProgressView()
                        .tint(Color(hex: 0x6C8CFF))
                }
            }
        }
        .task {
            await viewModel.loadUser()
        }
    }

    // MARK: - Profile Section

    private var profileSection: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader(title: "Profile", icon: "person.circle")

                if let user = viewModel.user {
                    profileRow(label: "Name", value: user.displayName)
                    profileRow(label: "Email", value: user.email)
                    profileRow(label: "Timezone", value: user.timezone)
                    profileRow(label: "Role", value: user.role.capitalized)
                } else {
                    Text("Loading...")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: 0x8B95A8))
                }
            }
        }
    }

    private func profileRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(Color(hex: 0x8B95A8))
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(hex: 0xE8ECF4))
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader(title: "Notifications", icon: "bell")

                if let user = viewModel.user {
                    notificationToggle(
                        label: "Daily DSAA Reminder",
                        isOn: Binding(
                            get: { user.notificationPreferences.dailyDsaaReminder },
                            set: { _ in Task { await viewModel.updateNotificationPreferences() } }
                        )
                    )
                    notificationToggle(
                        label: "Weekly Fill Reminder",
                        isOn: Binding(
                            get: { user.notificationPreferences.weeklyFillReminder },
                            set: { _ in Task { await viewModel.updateNotificationPreferences() } }
                        )
                    )
                    notificationToggle(
                        label: "Deep Work Start Alert",
                        isOn: Binding(
                            get: { user.notificationPreferences.deepWorkStartAlert },
                            set: { _ in Task { await viewModel.updateNotificationPreferences() } }
                        )
                    )
                    notificationToggle(
                        label: "Scorecard Friday Reminder",
                        isOn: Binding(
                            get: { user.notificationPreferences.scorecardFridayReminder },
                            set: { _ in Task { await viewModel.updateNotificationPreferences() } }
                        )
                    )
                    notificationToggle(
                        label: "Reactive Window Alerts",
                        isOn: Binding(
                            get: { user.notificationPreferences.reactiveWindowAlerts },
                            set: { _ in Task { await viewModel.updateNotificationPreferences() } }
                        )
                    )
                    notificationToggle(
                        label: "Incident Pipeline Check",
                        isOn: Binding(
                            get: { user.notificationPreferences.incidentPipelineCheck },
                            set: { _ in Task { await viewModel.updateNotificationPreferences() } }
                        )
                    )
                } else {
                    Text("Loading...")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: 0x8B95A8))
                }
            }
        }
    }

    private func notificationToggle(label: String, isOn: Binding<Bool>) -> some View {
        Toggle(label, isOn: isOn)
            .font(.subheadline)
            .foregroundColor(Color(hex: 0xE8ECF4))
            .tint(Color(hex: 0x6C8CFF))
    }

    // MARK: - DSAA Settings

    private var dsaaSettingsSection: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader(title: "DSAA Settings", icon: "bolt.circle")

                if let user = viewModel.user {
                    profileRow(label: "Trigger Time", value: user.dsaaTriggerTime)
                    profileRow(label: "Trigger Event", value: user.dsaaTriggerEvent.capitalized)
                } else {
                    Text("Loading...")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: 0x8B95A8))
                }
            }
        }
    }

    // MARK: - Deep Work

    private var deepWorkSection: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader(title: "Deep Work", icon: "brain")

                if let user = viewModel.user {
                    HStack {
                        Text("Weekly Hours Target")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: 0x8B95A8))
                        Spacer()
                        Text(String(format: "%.1fh", user.deepWorkHoursTarget))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: 0x6C8CFF))
                    }
                } else {
                    Text("Loading...")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: 0x8B95A8))
                }
            }
        }
    }

    // MARK: - Push Permission

    private var pushPermissionSection: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(title: "Push Notifications", icon: "app.badge")

                HStack {
                    Text("Permission Status")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: 0x8B95A8))
                    Spacer()
                    Text(viewModel.notificationPermissionGranted ? "Granted" : "Not Granted")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.notificationPermissionGranted ? Color(hex: 0x00D4AA) : Color(hex: 0xFFB84D))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            (viewModel.notificationPermissionGranted ? Color(hex: 0x00D4AA) : Color(hex: 0xFFB84D)).opacity(0.15)
                        )
                        .clipShape(Capsule())
                }

                if !viewModel.notificationPermissionGranted {
                    Button {
                        Task { await viewModel.requestNotificationPermission() }
                    } label: {
                        Text("Enable Push Notifications")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: 0x6C8CFF))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(hex: 0x6C8CFF).opacity(0.12))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }

    // MARK: - App Info

    private var appInfoSection: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(title: "About", icon: "info.circle")

                profileRow(label: "App", value: "EMOps")
                profileRow(label: "Version", value: "1.0.0")
                profileRow(label: "Platform", value: "iOS")
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: 0x6C8CFF))
            Text(title)
                .font(.headline)
                .foregroundColor(Color(hex: 0xE8ECF4))
        }
    }
}

#Preview {
    SettingsView()
}
