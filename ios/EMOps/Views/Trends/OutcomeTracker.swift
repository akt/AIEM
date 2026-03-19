import SwiftUI

struct OutcomeTracker: View {
    let trends: [TrendData]

    var body: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Weekly Outcomes")
                    .font(.headline)
                    .foregroundColor(Color(hex: 0xE8ECF4))

                if trends.isEmpty {
                    Text("No outcome data available")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: 0x8B95A8))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                } else {
                    VStack(spacing: 8) {
                        ForEach(Array(trends.enumerated()), id: \.offset) { _, trend in
                            HStack {
                                Text(weekLabel(trend.weekStart))
                                    .font(.caption)
                                    .foregroundColor(Color(hex: 0x8B95A8))
                                    .frame(width: 60, alignment: .leading)

                                // Progress bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color(hex: 0x242836))
                                            .frame(height: 20)

                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(outcomeColor(completed: trend.outcomesCompleted, total: trend.outcomesTotal))
                                            .frame(
                                                width: trend.outcomesTotal > 0
                                                    ? geometry.size.width * CGFloat(trend.outcomesCompleted) / CGFloat(trend.outcomesTotal)
                                                    : 0,
                                                height: 20
                                            )
                                    }
                                }
                                .frame(height: 20)

                                // Count
                                Text("\(trend.outcomesCompleted)/\(trend.outcomesTotal)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(outcomeColor(completed: trend.outcomesCompleted, total: trend.outcomesTotal))
                                    .frame(width: 36, alignment: .trailing)
                            }
                        }
                    }
                }
            }
        }
    }

    private func outcomeColor(completed: Int, total: Int) -> Color {
        guard total > 0 else { return Color(hex: 0x8B95A8) }
        let rate = Double(completed) / Double(total)
        if rate >= 0.8 {
            return Color(hex: 0x00D4AA)
        } else if rate >= 0.5 {
            return Color(hex: 0xFFB84D)
        } else {
            return Color(hex: 0xFF6B6B)
        }
    }

    private func weekLabel(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = inputFormatter.date(from: dateString) else { return dateString }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d"
        return outputFormatter.string(from: date)
    }
}

#Preview {
    ZStack {
        Color(hex: 0x0F1117).ignoresSafeArea()
        OutcomeTracker(trends: [])
            .padding()
    }
}
