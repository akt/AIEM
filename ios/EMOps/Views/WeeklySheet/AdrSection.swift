import SwiftUI

struct AdrSection: View {
    let sheet: WeeklySheet

    @State private var adrLinkExists: Bool = false
    @State private var alternativesConsidered: Bool = false
    @State private var rolloutRollbackPlan: Bool = false
    @State private var observabilityPlan: Bool = false
    @State private var dataContractsChecked: Bool = false

    var body: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundColor(Color(hex: 0x6C8CFF))
                    Text("ADR Checklist")
                        .font(.headline)
                        .foregroundColor(Color(hex: 0xE8ECF4))

                    Spacer()

                    completionBadge
                }

                checklistToggle(label: "ADR Link Exists", isOn: $adrLinkExists)
                checklistToggle(label: "Alternatives Considered", isOn: $alternativesConsidered)
                checklistToggle(label: "Rollout/Rollback Plan", isOn: $rolloutRollbackPlan)
                checklistToggle(label: "Observability Plan", isOn: $observabilityPlan)
                checklistToggle(label: "Data Contracts Checked", isOn: $dataContractsChecked)
            }
        }
        .onAppear {
            adrLinkExists = sheet.adrChecklist.adrLinkExists
            alternativesConsidered = sheet.adrChecklist.alternativesConsidered
            rolloutRollbackPlan = sheet.adrChecklist.rolloutRollbackPlan
            observabilityPlan = sheet.adrChecklist.observabilityPlan
            dataContractsChecked = sheet.adrChecklist.dataContractsChecked
        }
    }

    private var completionBadge: some View {
        let completed = [adrLinkExists, alternativesConsidered, rolloutRollbackPlan, observabilityPlan, dataContractsChecked]
            .filter { $0 }.count
        let total = 5
        let color: Color = completed == total ? Color(hex: 0x00D4AA) : Color(hex: 0x8B95A8)

        return Text("\(completed)/\(total)")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }

    private func checklistToggle(label: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 8) {
                Image(systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isOn.wrappedValue ? Color(hex: 0x00D4AA) : Color(hex: 0x8B95A8))
                    .font(.body)
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(Color(hex: 0xE8ECF4))
            }
        }
        .tint(Color(hex: 0x00D4AA))
        .toggleStyle(.switch)
    }
}

#Preview {
    ScrollView {
        AdrSection(sheet: PreviewData.sampleSheet)
            .padding()
    }
    .background(Color(hex: 0x0F1117))
}
