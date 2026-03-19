import SwiftUI

struct WeekSummaryCard: View {
    let dsaaStreak: Int
    let deepWorkHours: Double
    let deepWorkTarget: Double
    let habitsCompleted: Int
    let habitsTotal: Int

    var body: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Weekly Stats")
                    .font(.headline)
                    .foregroundColor(Color(hex: 0xE8ECF4))

                HStack(spacing: 0) {
                    statItem(
                        icon: "flame.fill",
                        value: "\(dsaaStreak)",
                        label: "DSAA Streak",
                        color: Color(hex: 0xFFB84D)
                    )

                    Spacer()

                    statItem(
                        icon: "brain",
                        value: deepWorkProgress,
                        label: "Deep Work",
                        color: Color(hex: 0x6C8CFF)
                    )

                    Spacer()

                    statItem(
                        icon: "checkmark.circle",
                        value: "\(habitsCompleted)/\(habitsTotal)",
                        label: "Habits Today",
                        color: Color(hex: 0x00D4AA)
                    )
                }

                // Deep work progress bar
                VStack(alignment: .leading, spacing: 4) {
                    Text("Deep Work Progress")
                        .font(.caption2)
                        .foregroundColor(Color(hex: 0x8B95A8))
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: 0x242836))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: 0x6C8CFF))
                                .frame(width: geo.size.width * deepWorkFraction, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
    }

    private var deepWorkProgress: String {
        let hours = String(format: "%.1f", deepWorkHours)
        let target = String(format: "%.0f", deepWorkTarget)
        return "\(hours)/\(target)h"
    }

    private var deepWorkFraction: CGFloat {
        guard deepWorkTarget > 0 else { return 0 }
        return min(CGFloat(deepWorkHours / deepWorkTarget), 1.0)
    }

    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: 0xE8ECF4))
            Text(label)
                .font(.caption2)
                .foregroundColor(Color(hex: 0x8B95A8))
        }
    }
}

#Preview {
    WeekSummaryCard(
        dsaaStreak: 5,
        deepWorkHours: 12.5,
        deepWorkTarget: 20,
        habitsCompleted: 3,
        habitsTotal: 5
    )
    .padding()
    .background(Color(hex: 0x0F1117))
}
