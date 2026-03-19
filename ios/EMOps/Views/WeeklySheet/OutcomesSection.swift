import SwiftUI

struct OutcomesSection: View {
    @Binding var outcomes: [Outcome]
    let onAdd: (String, String, String, String, String) -> Void
    let onDelete: (String) -> Void
    let onStatusChange: (String, Outcome.OutcomeStatus) -> Void

    @State private var isAddingOutcome = false
    @State private var newOutcomeText = ""
    @State private var newImpact = ""
    @State private var newDod = ""
    @State private var newOwner = ""
    @State private var newRisk = ""

    var body: some View {
        VStack(spacing: 16) {
            // Header with add button
            HStack {
                sectionHeader(title: "Top 3 Outcomes", icon: "target")
                Spacer()
                if outcomes.count < 3 {
                    Button {
                        isAddingOutcome.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(hex: 0x6C8CFF))
                            .font(.title3)
                    }
                }
            }

            // Existing outcomes
            ForEach(outcomes) { outcome in
                outcomeRow(outcome)
            }

            // Add outcome form
            if isAddingOutcome {
                addOutcomeForm
            }
        }
    }

    private func outcomeRow(_ outcome: Outcome) -> some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("#\(outcome.position)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: 0x6C8CFF))

                    Text(outcome.outcomeText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: 0xE8ECF4))

                    Spacer()

                    Button {
                        onDelete(outcome.id)
                    } label: {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(Color(hex: 0xFF6B6B))
                    }
                }

                if !outcome.impact.isEmpty {
                    detailRow(label: "Impact", value: outcome.impact)
                }

                if !outcome.definitionOfDone.isEmpty {
                    detailRow(label: "Definition of Done", value: outcome.definitionOfDone)
                }

                if !outcome.owner.isEmpty {
                    detailRow(label: "Owner", value: outcome.owner)
                }

                if !outcome.riskAndMitigation.isEmpty {
                    detailRow(label: "Risk & Mitigation", value: outcome.riskAndMitigation)
                }

                // Status picker
                HStack {
                    Text("Status")
                        .font(.caption)
                        .foregroundColor(Color(hex: 0x8B95A8))
                    Spacer()
                    Picker("Status", selection: Binding(
                        get: { outcome.status },
                        set: { newStatus in onStatusChange(outcome.id, newStatus) }
                    )) {
                        ForEach(Outcome.OutcomeStatus.allCases, id: \.self) { status in
                            Text(statusLabel(status))
                                .tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(statusColor(outcome.status))
                }
            }
        }
    }

    private var addOutcomeForm: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("New Outcome")
                    .font(.headline)
                    .foregroundColor(Color(hex: 0xE8ECF4))

                formField(label: "Outcome", text: $newOutcomeText, placeholder: "What will you achieve?")
                formField(label: "Impact", text: $newImpact, placeholder: "Why does this matter?")
                formField(label: "Definition of Done", text: $newDod, placeholder: "How will you know it's done?")
                formField(label: "Owner", text: $newOwner, placeholder: "Who is responsible?")
                formField(label: "Risk & Mitigation", text: $newRisk, placeholder: "What could go wrong?")

                HStack(spacing: 12) {
                    Button("Cancel") {
                        isAddingOutcome = false
                        clearForm()
                    }
                    .font(.subheadline)
                    .foregroundColor(Color(hex: 0x8B95A8))

                    Spacer()

                    Button("Add Outcome") {
                        onAdd(newOutcomeText, newImpact, newDod, newOwner, newRisk)
                        isAddingOutcome = false
                        clearForm()
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: 0x0F1117))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: 0x6C8CFF))
                    .cornerRadius(8)
                    .disabled(newOutcomeText.isEmpty)
                }
            }
        }
    }

    private func formField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: 0x8B95A8))
                .textCase(.uppercase)
            TextField(placeholder, text: text)
                .font(.subheadline)
                .foregroundColor(Color(hex: 0xE8ECF4))
                .padding(10)
                .background(Color(hex: 0x242836))
                .cornerRadius(8)
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(Color(hex: 0x8B95A8))
            Text(value)
                .font(.caption)
                .foregroundColor(Color(hex: 0xE8ECF4))
        }
    }

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: 0x6C8CFF))
            Text(title)
                .font(.headline)
                .foregroundColor(Color(hex: 0xE8ECF4))
        }
    }

    private func statusLabel(_ status: Outcome.OutcomeStatus) -> String {
        switch status {
        case .inProgress: return "In Progress"
        case .done: return "Done"
        case .blocked: return "Blocked"
        case .carriedOver: return "Carried Over"
        }
    }

    private func statusColor(_ status: Outcome.OutcomeStatus) -> Color {
        switch status {
        case .done: return Color(hex: 0x00D4AA)
        case .inProgress: return Color(hex: 0x6C8CFF)
        case .blocked: return Color(hex: 0xFF6B6B)
        case .carriedOver: return Color(hex: 0xFFB84D)
        }
    }

    private func clearForm() {
        newOutcomeText = ""
        newImpact = ""
        newDod = ""
        newOwner = ""
        newRisk = ""
    }
}

#Preview {
    ScrollView {
        OutcomesSection(
            outcomes: .constant([]),
            onAdd: { _, _, _, _, _ in },
            onDelete: { _ in },
            onStatusChange: { _, _ in }
        )
        .padding()
    }
    .background(Color(hex: 0x0F1117))
}
