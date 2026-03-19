import SwiftUI
import Charts

struct HabitCompletionChart: View {
    let trends: [TrendData]

    var body: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Habit Completion Rate")
                    .font(.headline)
                    .foregroundColor(Color(hex: 0xE8ECF4))

                Chart {
                    ForEach(Array(trends.enumerated()), id: \.offset) { _, trend in
                        let rate = trend.habitsCompletionRate * 100

                        BarMark(
                            x: .value("Week", weekLabel(trend.weekStart)),
                            y: .value("Rate", rate)
                        )
                        .foregroundStyle(barColor(rate: rate))
                        .cornerRadius(4)
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: 0...100)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color(hex: 0x8B95A8))
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color(hex: 0x242836))
                        AxisValueLabel {
                            Text("\(Int($0.as(Double.self) ?? 0))%")
                                .foregroundColor(Color(hex: 0x8B95A8))
                        }
                    }
                }

                // Legend
                HStack(spacing: 16) {
                    legendItem(color: Color(hex: 0x00D4AA), label: ">80%")
                    legendItem(color: Color(hex: 0xFFB84D), label: "50-80%")
                    legendItem(color: Color(hex: 0xFF6B6B), label: "<50%")
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    private func barColor(rate: Double) -> Color {
        if rate >= 80 {
            return Color(hex: 0x00D4AA)
        } else if rate >= 50 {
            return Color(hex: 0xFFB84D)
        } else {
            return Color(hex: 0xFF6B6B)
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption2)
                .foregroundColor(Color(hex: 0x8B95A8))
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
        HabitCompletionChart(trends: [])
            .padding()
    }
}
