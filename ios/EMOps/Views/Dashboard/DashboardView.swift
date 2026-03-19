import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Greeting with week number
                    greetingSection

                    // Streak / Stats card
                    WeekSummaryCard(
                        dsaaStreak: viewModel.dsaaStreak,
                        deepWorkHours: viewModel.dashboardData?.weeklyProgress.deepWorkHoursThisWeek ?? 0,
                        deepWorkTarget: viewModel.dashboardData?.weeklyProgress.deepWorkHoursTarget ?? 20,
                        habitsCompleted: viewModel.todayHabitsCompleted,
                        habitsTotal: viewModel.todayHabitsTotal
                    )

                    // This Week's Focus
                    if let sheet = viewModel.currentSheet {
                        weekFocusCard(sheet: sheet)
                    }

                    // Top 3 Outcomes
                    if let sheet = viewModel.currentSheet, !sheet.outcomes.isEmpty {
                        OutcomesCard(outcomes: Array(sheet.outcomes.prefix(3)))
                    }

                    // AI Coach
                    if let note = viewModel.aiCoachingNote, !note.isEmpty {
                        aiCoachCard(note: note)
                    }

                    // Upcoming reminders
                    if !viewModel.upcomingReminders.isEmpty {
                        UpcomingCard(reminders: viewModel.upcomingReminders)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color(hex: 0x0F1117).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("EMOPS")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: EmptyView()) {
                        Image(systemName: "gearshape")
                            .foregroundColor(Color(hex: 0x8B95A8))
                    }
                }
            }
            .refreshable {
                await viewModel.refreshData()
            }
            .overlay {
                if viewModel.isLoading && viewModel.dashboardData == nil {
                    ProgressView()
                        .tint(Color(hex: 0x6C8CFF))
                }
            }
        }
        .task {
            await viewModel.loadDashboard()
        }
    }

    // MARK: - Greeting

    private var greetingSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: 0xE8ECF4))
                Text(weekLabel)
                    .font(.subheadline)
                    .foregroundColor(Color(hex: 0x8B95A8))
            }
            Spacer()
        }
        .padding(.top, 8)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning!" }
        if hour < 17 { return "Good afternoon!" }
        return "Good evening!"
    }

    private var weekLabel: String {
        let week = Calendar.current.component(.weekOfYear, from: Date())
        let year = Calendar.current.component(.year, from: Date())
        return "Week \(week), \(year)"
    }

    // MARK: - Week Focus Card

    private func weekFocusCard(sheet: WeeklySheet) -> some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("This Week's Focus")
                    .font(.headline)
                    .foregroundColor(Color(hex: 0xE8ECF4))

                if !sheet.constraintStatement.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Constraint")
                            .font(.caption)
                            .foregroundColor(Color(hex: 0x8B95A8))
                        Text(sheet.constraintStatement)
                            .font(.subheadline)
                            .foregroundColor(Color(hex: 0xE8ECF4))
                    }
                }

                HStack(spacing: 12) {
                    errorBudgetBadge(status: sheet.constraintErrorBudgetStatus)

                    dsaaFocusBadge(focus: sheet.dsaaFocusThisWeek)
                }
            }
        }
    }

    private func errorBudgetBadge(status: WeeklySheet.ErrorBudgetStatus) -> some View {
        let color: Color = {
            switch status {
            case .healthy: return Color(hex: 0x00D4AA)
            case .burning: return Color(hex: 0xFFB84D)
            case .exhausted: return Color(hex: 0xFF6B6B)
            }
        }()

        return Text(status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }

    private func dsaaFocusBadge(focus: WeeklySheet.DsaaFocus) -> some View {
        let color: Color = {
            switch focus {
            case .delete: return Color(hex: 0xFF6B6B)
            case .simplify: return Color(hex: 0xFFB84D)
            case .accelerate: return Color(hex: 0x6C8CFF)
            case .automate: return Color(hex: 0x00D4AA)
            }
        }()

        return HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(focus.rawValue.capitalized)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }

    // MARK: - AI Coach Card

    private func aiCoachCard(note: String) -> some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(Color(hex: 0x6C8CFF))
                    Text("AI Coach")
                        .font(.headline)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                }
                Text(note)
                    .font(.subheadline)
                    .foregroundColor(Color(hex: 0x8B95A8))
                    .lineLimit(4)
            }
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

// MARK: - EMOpsCard Component (placeholder wrapper)

struct EMOpsCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: 0x1A1D27))
            .cornerRadius(12)
    }
}

#Preview {
    DashboardView()
}
