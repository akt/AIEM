import SwiftUI

struct HabitDetailView: View {
    let habit: Habit

    // Simulated completion data for last 30 days
    @State private var completedDays: Set<Int> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Name and description
                infoSection

                // Stats
                statsSection

                // Calendar grid (last 30 days)
                calendarSection

                // Details
                detailsSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color(hex: 0x0F1117).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Habit Detail")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: 0xE8ECF4))
            }
        }
        .onAppear {
            // Simulate some completed days based on streak
            var days: Set<Int> = []
            for i in 0..<min(habit.streakCurrent, 30) {
                days.insert(29 - i)
            }
            completedDays = days
        }
    }

    // MARK: - Info Section

    private var infoSection: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(habit.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: 0xE8ECF4))

                if !habit.description.isEmpty {
                    Text(habit.description)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: 0x8B95A8))
                }

                HStack(spacing: 8) {
                    categoryBadge
                    frequencyBadge
                }
                .padding(.top, 4)
            }
        }
    }

    private var categoryBadge: some View {
        Text(habit.category.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(Color(hex: 0x6C8CFF))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(hex: 0x6C8CFF).opacity(0.15))
            .clipShape(Capsule())
    }

    private var frequencyBadge: some View {
        Text(habit.frequency.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(Color(hex: 0x8B95A8))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(hex: 0x242836))
            .clipShape(Capsule())
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Stats")
                    .font(.headline)
                    .foregroundColor(Color(hex: 0xE8ECF4))

                HStack(spacing: 16) {
                    statItem(
                        label: "Current Streak",
                        value: "\(habit.streakCurrent)",
                        icon: "flame.fill",
                        color: Color(hex: 0xFFB84D)
                    )
                    statItem(
                        label: "Best Streak",
                        value: "\(habit.streakBest)",
                        icon: "trophy.fill",
                        color: Color(hex: 0x00D4AA)
                    )
                    if habit.targetUnit != .boolean {
                        statItem(
                            label: "Target",
                            value: formattedTarget,
                            icon: "target",
                            color: Color(hex: 0x6C8CFF)
                        )
                    }
                }
            }
        }
    }

    private func statItem(label: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: 0xE8ECF4))
            Text(label)
                .font(.caption2)
                .foregroundColor(Color(hex: 0x8B95A8))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Calendar Section

    private var calendarSection: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Last 30 Days")
                    .font(.headline)
                    .foregroundColor(Color(hex: 0xE8ECF4))

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                    ForEach(0..<30, id: \.self) { dayIndex in
                        let isCompleted = completedDays.contains(dayIndex)
                        Circle()
                            .fill(isCompleted ? Color(hex: 0x00D4AA) : Color(hex: 0x242836))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Text(dayLabel(for: dayIndex))
                                    .font(.system(size: 10))
                                    .foregroundColor(
                                        isCompleted ? Color(hex: 0x0F1117) : Color(hex: 0x8B95A8)
                                    )
                            )
                    }
                }
            }
        }
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Details")
                    .font(.headline)
                    .foregroundColor(Color(hex: 0xE8ECF4))

                detailRow(label: "Target", value: "\(formattedTarget) \(habit.targetUnit.rawValue)")
                detailRow(label: "Frequency", value: habit.frequency.rawValue.capitalized)
                detailRow(label: "Reminder", value: habit.reminderEnabled ? (habit.reminderTime ?? "Enabled") : "Disabled")
                detailRow(label: "Status", value: habit.isActive ? "Active" : "Inactive")
            }
        }
    }

    private func detailRow(label: String, value: String) -> some View {
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

    // MARK: - Helpers

    private var formattedTarget: String {
        if habit.targetValue == floor(habit.targetValue) {
            return String(Int(habit.targetValue))
        }
        return String(format: "%.1f", habit.targetValue)
    }

    private func dayLabel(for index: Int) -> String {
        let calendar = Calendar.current
        guard let date = calendar.date(byAdding: .day, value: -(29 - index), to: Date()) else {
            return ""
        }
        return "\(calendar.component(.day, from: date))"
    }
}

#Preview {
    NavigationStack {
        HabitDetailView(habit: Habit(
            id: "1", userId: "u1", name: "Deep Work Block",
            description: "Complete a 2-hour focused work session without distractions",
            category: .deepWork, frequency: .daily, customDays: nil,
            targetValue: 2, targetUnit: .hours,
            reminderTime: "09:00", reminderEnabled: true,
            streakCurrent: 12, streakBest: 25,
            isActive: true, sortOrder: 0
        ))
    }
}
