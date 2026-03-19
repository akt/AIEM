import SwiftUI

struct HabitRow: View {
    let habit: Habit
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button {
                onToggle()
            } label: {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isCompleted ? Color(hex: 0x00D4AA) : Color(hex: 0x8B95A8))
            }
            .buttonStyle(.plain)

            // Habit info
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(
                        isCompleted ? Color(hex: 0x8B95A8) : Color(hex: 0xE8ECF4)
                    )
                    .strikethrough(isCompleted, color: Color(hex: 0x8B95A8))

                if habit.targetUnit != .boolean {
                    Text("\(formattedTarget) \(habit.targetUnit.rawValue)")
                        .font(.caption)
                        .foregroundColor(Color(hex: 0x8B95A8))
                }
            }

            Spacer()

            // Streak indicator
            if habit.streakCurrent > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.caption2)
                        .foregroundColor(Color(hex: 0xFFB84D))
                    Text("\(habit.streakCurrent)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0xFFB84D))
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(hex: 0xFFB84D).opacity(0.12))
                .clipShape(Capsule())
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Color(hex: 0x8B95A8).opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var formattedTarget: String {
        if habit.targetValue == floor(habit.targetValue) {
            return String(Int(habit.targetValue))
        }
        return String(format: "%.1f", habit.targetValue)
    }
}

#Preview {
    ZStack {
        Color(hex: 0x0F1117).ignoresSafeArea()
        VStack(spacing: 0) {
            HabitRow(
                habit: Habit(
                    id: "1", userId: "u1", name: "Deep Work Block",
                    description: "Complete a focused work session",
                    category: .deepWork, frequency: .daily, customDays: nil,
                    targetValue: 2, targetUnit: .hours,
                    reminderTime: nil, reminderEnabled: false,
                    streakCurrent: 5, streakBest: 12,
                    isActive: true, sortOrder: 0
                ),
                isCompleted: false,
                onToggle: {}
            )
            HabitRow(
                habit: Habit(
                    id: "2", userId: "u1", name: "Review Alerts",
                    description: "Check monitoring alerts",
                    category: .reliability, frequency: .daily, customDays: nil,
                    targetValue: 1, targetUnit: .boolean,
                    reminderTime: nil, reminderEnabled: false,
                    streakCurrent: 0, streakBest: 3,
                    isActive: true, sortOrder: 1
                ),
                isCompleted: true,
                onToggle: {}
            )
        }
        .background(Color(hex: 0x1A1D27))
        .cornerRadius(12)
        .padding()
    }
}
