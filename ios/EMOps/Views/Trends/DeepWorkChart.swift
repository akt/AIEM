import SwiftUI
import Charts

struct DeepWorkChart: View {
    let trends: [TrendData]

    private let targetHours: Double = 7.5

    var body: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Deep Work Hours")
                    .font(.headline)
                    .foregroundColor(Color(hex: 0xE8ECF4))

                Chart {
                    ForEach(Array(trends.enumerated()), id: \.offset) { index, trend in
                        LineMark(
                            x: .value("Week", weekLabel(trend.weekStart)),
                            y: .value("Hours", trend.deepWorkHoursTotal)
                        )
                        .foregroundStyle(Color(hex: 0x6C8CFF))
                        .interpolationMethod(.catmullRom)
                        .symbol(Circle())
                        .symbolSize(30)

                        AreaMark(
                            x: .value("Week", weekLabel(trend.weekStart)),
                            y: .value("Hours", trend.deepWorkHoursTotal)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: 0x6C8CFF).opacity(0.3), Color(hex: 0x6C8CFF).opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }

                    // Target line
                    RuleMark(y: .value("Target", targetHours))
                        .foregroundStyle(Color(hex: 0xFFB84D))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Target: \(String(format: "%.1f", targetHours))h")
                                .font(.caption2)
                                .foregroundColor(Color(hex: 0xFFB84D))
                        }
                }
                .frame(height: 200)
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
                        AxisValueLabel()
                            .foregroundStyle(Color(hex: 0x8B95A8))
                    }
                }
            }
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
        DeepWorkChart(trends: [])
            .padding()
    }
}
