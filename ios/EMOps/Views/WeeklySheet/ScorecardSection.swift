import SwiftUI

struct ScorecardSection: View {
    let sheet: WeeklySheet

    // DORA
    @State private var deployFreq = EditableMetric()
    @State private var leadTime = EditableMetric()
    @State private var changeFailRate = EditableMetric()
    @State private var timeToRestore = EditableMetric()

    // SLO
    @State private var compliance = EditableMetric()
    @State private var errorBudgetBurn = EditableMetric()

    // SPACE
    @State private var deepWorkHours = EditableMetric()
    @State private var frictionPulse = EditableMetric()

    // AI Health
    @State private var assistedPct = EditableMetric()
    @State private var riskCatches = EditableMetric()

    var body: some View {
        VStack(spacing: 16) {
            // DORA Metrics
            metricGroup(
                title: "DORA Metrics",
                icon: "gauge.with.dots.needle.33percent",
                color: Color(hex: 0x6C8CFF),
                metrics: [
                    ("Deploy Frequency", $deployFreq),
                    ("Lead Time", $leadTime),
                    ("Change Fail Rate", $changeFailRate),
                    ("Time to Restore", $timeToRestore)
                ]
            )

            // SLO Metrics
            metricGroup(
                title: "SLO Metrics",
                icon: "chart.bar.xaxis",
                color: Color(hex: 0x00D4AA),
                metrics: [
                    ("Compliance", $compliance),
                    ("Error Budget Burn", $errorBudgetBurn)
                ]
            )

            // SPACE Metrics
            metricGroup(
                title: "SPACE Metrics",
                icon: "person.3",
                color: Color(hex: 0xFFB84D),
                metrics: [
                    ("Deep Work Hours", $deepWorkHours),
                    ("Friction Pulse", $frictionPulse)
                ]
            )

            // AI Health Metrics
            metricGroup(
                title: "AI Health",
                icon: "cpu",
                color: Color(hex: 0x6C8CFF),
                metrics: [
                    ("Assisted %", $assistedPct),
                    ("Risk Catches", $riskCatches)
                ]
            )
        }
        .onAppear {
            guard let scorecard = sheet.scorecard else { return }

            deployFreq = EditableMetric(from: scorecard.dora.deployFreq)
            leadTime = EditableMetric(from: scorecard.dora.leadTime)
            changeFailRate = EditableMetric(from: scorecard.dora.changeFailRate)
            timeToRestore = EditableMetric(from: scorecard.dora.timeToRestore)

            compliance = EditableMetric(from: scorecard.slo.compliance)
            errorBudgetBurn = EditableMetric(from: scorecard.slo.errorBudgetBurn)

            deepWorkHours = EditableMetric(from: scorecard.space.deepWorkHours)
            frictionPulse = EditableMetric(from: scorecard.space.frictionPulse)

            assistedPct = EditableMetric(from: scorecard.aiHealth.assistedPct)
            riskCatches = EditableMetric(from: scorecard.aiHealth.riskCatches)
        }
    }

    private func metricGroup(
        title: String,
        icon: String,
        color: Color,
        metrics: [(String, Binding<EditableMetric>)]
    ) -> some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundColor(color)
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                }

                ForEach(Array(metrics.enumerated()), id: \.offset) { index, item in
                    let (label, binding) = item
                    metricEntryView(label: label, color: color, metric: binding)

                    if index < metrics.count - 1 {
                        Divider()
                            .background(Color(hex: 0x242836))
                    }
                }
            }
        }
    }

    private func metricEntryView(label: String, color: Color, metric: Binding<EditableMetric>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)

            if !metric.wrappedValue.definition.isEmpty {
                Text(metric.wrappedValue.definition)
                    .font(.caption2)
                    .foregroundColor(Color(hex: 0x8B95A8))
                    .italic()
            }

            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("THIS WEEK")
                        .font(.caption2)
                        .foregroundColor(Color(hex: 0x8B95A8))
                    TextField("Value", text: metric.thisWeek)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                        .padding(8)
                        .background(Color(hex: 0x242836))
                        .cornerRadius(6)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("TARGET")
                        .font(.caption2)
                        .foregroundColor(Color(hex: 0x8B95A8))
                    TextField("Target", text: metric.target)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                        .padding(8)
                        .background(Color(hex: 0x242836))
                        .cornerRadius(6)
                }
            }

            TextField("Notes", text: metric.notes)
                .font(.caption)
                .foregroundColor(Color(hex: 0x8B95A8))
                .padding(8)
                .background(Color(hex: 0x242836))
                .cornerRadius(6)
        }
    }
}

// MARK: - Editable Metric

struct EditableMetric {
    var definition: String = ""
    var thisWeek: String = ""
    var target: String = ""
    var notes: String = ""

    init() {}

    init(from entry: MetricEntry) {
        definition = entry.definition
        thisWeek = entry.thisWeek
        target = entry.target
        notes = entry.notes
    }
}

#Preview {
    ScrollView {
        ScorecardSection(sheet: PreviewData.sampleSheet)
            .padding()
    }
    .background(Color(hex: 0x0F1117))
}
