import SwiftUI

struct OutcomesCard: View {
    let outcomes: [Outcome]

    var body: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Top 3 Outcomes")
                    .font(.headline)
                    .foregroundColor(Color(hex: 0xE8ECF4))

                ForEach(outcomes) { outcome in
                    HStack(spacing: 10) {
                        statusIcon(for: outcome.status)
                            .frame(width: 24, height: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(outcome.outcomeText)
                                .font(.subheadline)
                                .foregroundColor(Color(hex: 0xE8ECF4))
                                .lineLimit(2)
                            Text(outcome.owner)
                                .font(.caption)
                                .foregroundColor(Color(hex: 0x8B95A8))
                        }

                        Spacer()

                        statusBadge(for: outcome.status)
                    }

                    if outcome.id != outcomes.last?.id {
                        Divider()
                            .background(Color(hex: 0x242836))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func statusIcon(for status: Outcome.OutcomeStatus) -> some View {
        switch status {
        case .done:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(hex: 0x00D4AA))
        case .inProgress:
            Image(systemName: "arrow.forward.circle.fill")
                .foregroundColor(Color(hex: 0x6C8CFF))
        case .blocked:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(Color(hex: 0xFF6B6B))
        case .carriedOver:
            Image(systemName: "arrow.uturn.forward.circle.fill")
                .foregroundColor(Color(hex: 0xFFB84D))
        }
    }

    private func statusBadge(for status: Outcome.OutcomeStatus) -> some View {
        let label: String
        let color: Color

        switch status {
        case .done:
            label = "Done"
            color = Color(hex: 0x00D4AA)
        case .inProgress:
            label = "In Progress"
            color = Color(hex: 0x6C8CFF)
        case .blocked:
            label = "Blocked"
            color = Color(hex: 0xFF6B6B)
        case .carriedOver:
            label = "Carried"
            color = Color(hex: 0xFFB84D)
        }

        return Text(label)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}

#Preview {
    OutcomesCard(outcomes: [])
        .padding()
        .background(Color(hex: 0x0F1117))
}
