import SwiftUI

struct IncidentSection: View {
    let sheet: WeeklySheet

    @State private var p0p1Reviewed: Bool = false
    @State private var postmortemScheduled: Bool = false
    @State private var actionItemsOwned: Bool = false
    @State private var runbooksUpdated: Bool = false
    @State private var preventionBetChosen: Bool = false

    var body: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.shield")
                        .foregroundColor(Color(hex: 0xFF6B6B))
                    Text("Incident Readiness")
                        .font(.headline)
                        .foregroundColor(Color(hex: 0xE8ECF4))

                    Spacer()

                    completionBadge
                }

                checklistToggle(label: "P0/P1 Incidents Reviewed", isOn: $p0p1Reviewed)
                checklistToggle(label: "Postmortem Scheduled", isOn: $postmortemScheduled)
                checklistToggle(label: "Action Items Owned", isOn: $actionItemsOwned)
                checklistToggle(label: "Runbooks Updated", isOn: $runbooksUpdated)
                checklistToggle(label: "Prevention Bet Chosen", isOn: $preventionBetChosen)
            }
        }
        .onAppear {
            p0p1Reviewed = sheet.incidentChecklist.p0p1Reviewed
            postmortemScheduled = sheet.incidentChecklist.postmortemScheduled
            actionItemsOwned = sheet.incidentChecklist.actionItemsOwned
            runbooksUpdated = sheet.incidentChecklist.runbooksUpdated
            preventionBetChosen = sheet.incidentChecklist.preventionBetChosen
        }
    }

    private var completionBadge: some View {
        let completed = [p0p1Reviewed, postmortemScheduled, actionItemsOwned, runbooksUpdated, preventionBetChosen]
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
        IncidentSection(sheet: PreviewData.sampleSheet)
            .padding()
    }
    .background(Color(hex: 0x0F1117))
}
