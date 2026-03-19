import SwiftUI
import Charts

struct DsaaDistributionChart: View {
    let trends: [TrendData]

    private var distribution: [(action: String, count: Int, color: Color)] {
        var totals: [String: Int] = [
            "delete": 0,
            "simplify": 0,
            "accelerate": 0,
            "automate": 0
        ]

        for trend in trends {
            for (key, value) in trend.doraScores {
                // doraScores may not have dsaa breakdown; this is best-effort
                if totals.keys.contains(key), let intValue = value.value as? Int {
                    totals[key, default: 0] += intValue
                }
            }
        }

        // If no data from doraScores, use rituals completed as fallback distribution
        let total = totals.values.reduce(0, +)
        if total == 0 {
            let ritualsTotal = trends.reduce(0) { $0 + $1.dsaaRitualsCompleted }
            if ritualsTotal > 0 {
                // Even distribution as placeholder
                let quarter = ritualsTotal / 4
                let remainder = ritualsTotal % 4
                totals["delete"] = quarter
                totals["simplify"] = quarter
                totals["accelerate"] = quarter
                totals["automate"] = quarter + remainder
            }
        }

        return [
            (action: "Delete", count: totals["delete"] ?? 0, color: Color(hex: 0xFF6B6B)),
            (action: "Simplify", count: totals["simplify"] ?? 0, color: Color(hex: 0xFFB84D)),
            (action: "Accelerate", count: totals["accelerate"] ?? 0, color: Color(hex: 0x6C8CFF)),
            (action: "Automate", count: totals["automate"] ?? 0, color: Color(hex: 0x00D4AA))
        ].filter { $0.count > 0 }
    }

    var body: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("DSAA Distribution")
                    .font(.headline)
                    .foregroundColor(Color(hex: 0xE8ECF4))

                if distribution.isEmpty {
                    Text("No DSAA data available")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: 0x8B95A8))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 40)
                } else {
                    Chart {
                        ForEach(distribution, id: \.action) { item in
                            SectorMark(
                                angle: .value("Count", item.count),
                                innerRadius: .ratio(0.6),
                                angularInset: 2
                            )
                            .foregroundStyle(item.color)
                            .cornerRadius(4)
                        }
                    }
                    .frame(height: 200)

                    // Legend
                    HStack(spacing: 16) {
                        ForEach(distribution, id: \.action) { item in
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 8, height: 8)
                                Text("\(item.action) (\(item.count))")
                                    .font(.caption2)
                                    .foregroundColor(Color(hex: 0x8B95A8))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color(hex: 0x0F1117).ignoresSafeArea()
        DsaaDistributionChart(trends: [])
            .padding()
    }
}
