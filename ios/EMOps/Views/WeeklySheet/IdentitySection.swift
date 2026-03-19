import SwiftUI

struct IdentitySection: View {
    let sheet: WeeklySheet

    @State private var surfacesText: String = ""
    @State private var oncallOwnership: String = ""
    @State private var keyDependencies: String = ""
    @State private var nonNegotiableConstraints: String = ""

    var body: some View {
        VStack(spacing: 16) {
            EMOpsCard {
                VStack(alignment: .leading, spacing: 16) {
                    sectionHeader(title: "Identity & Scope", icon: "person.crop.rectangle")

                    // Surfaces in Scope (tags)
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("Surfaces in Scope")
                        Text("Comma-separated tags")
                            .font(.caption2)
                            .foregroundColor(Color(hex: 0x8B95A8))
                        TextEditor(text: $surfacesText)
                            .scrollContentBackground(.hidden)
                            .font(.subheadline)
                            .foregroundColor(Color(hex: 0xE8ECF4))
                            .frame(minHeight: 44)
                            .padding(8)
                            .background(Color(hex: 0x242836))
                            .cornerRadius(8)

                        // Tag pills display
                        if !surfacesText.isEmpty {
                            FlowLayout(spacing: 6) {
                                ForEach(parseTags(surfacesText), id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .foregroundColor(Color(hex: 0x6C8CFF))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color(hex: 0x6C8CFF).opacity(0.12))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    // Oncall Ownership
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("Oncall Ownership")
                        TextEditor(text: $oncallOwnership)
                            .scrollContentBackground(.hidden)
                            .font(.subheadline)
                            .foregroundColor(Color(hex: 0xE8ECF4))
                            .frame(minHeight: 60)
                            .padding(8)
                            .background(Color(hex: 0x242836))
                            .cornerRadius(8)
                    }

                    // Key Dependencies
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("Key Dependencies")
                        TextEditor(text: $keyDependencies)
                            .scrollContentBackground(.hidden)
                            .font(.subheadline)
                            .foregroundColor(Color(hex: 0xE8ECF4))
                            .frame(minHeight: 60)
                            .padding(8)
                            .background(Color(hex: 0x242836))
                            .cornerRadius(8)
                    }

                    // Non-Negotiable Constraints
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("Non-Negotiable Constraints")
                        TextEditor(text: $nonNegotiableConstraints)
                            .scrollContentBackground(.hidden)
                            .font(.subheadline)
                            .foregroundColor(Color(hex: 0xE8ECF4))
                            .frame(minHeight: 60)
                            .padding(8)
                            .background(Color(hex: 0x242836))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .onAppear {
            surfacesText = sheet.surfacesInScope.joined(separator: ", ")
            oncallOwnership = sheet.oncallOwnership
            keyDependencies = sheet.keyDependencies
            nonNegotiableConstraints = sheet.nonNegotiableConstraints
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(Color(hex: 0x8B95A8))
            .textCase(.uppercase)
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

    private func parseTags(_ text: String) -> [String] {
        text.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}

// MARK: - Flow Layout for Tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(subviews: subviews, width: proposal.width ?? 0)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(subviews: subviews, width: bounds.width)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(subviews: Subviews, width: CGFloat) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxWidth = max(maxWidth, x)
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}

#Preview {
    ScrollView {
        IdentitySection(sheet: PreviewData.sampleSheet)
            .padding()
    }
    .background(Color(hex: 0x0F1117))
}

// MARK: - Preview Helpers

enum PreviewData {
    static let sampleSheet = WeeklySheet(
        id: "preview-1",
        userId: "user-1",
        weekStart: "2026-03-16",
        weekLabel: "Week 12, 2026",
        status: .active,
        surfacesInScope: ["API Gateway", "Auth Service", "Dashboard"],
        oncallOwnership: "Primary oncall for API tier",
        keyDependencies: "Platform team for infra changes",
        nonNegotiableConstraints: "No deploys on Friday after 2pm",
        constraintStatement: "API latency p99 > 500ms blocking feature rollout",
        constraintEvidence: ConstraintEvidence(
            sliDashboards: "Grafana API dashboard",
            incidentPattern: "2 P1s last week",
            queueLag: "Deploy queue 3h",
            costRegression: "None"
        ),
        constraintSloService: "api-gateway",
        constraintSloTargets: "99.9% availability, p99 < 200ms",
        constraintErrorBudgetStatus: .healthy,
        constraintExhaustedAction: "Freeze features, fix reliability",
        dsaaQueue: DsaaQueue(
            delete: ["Legacy auth endpoint"],
            simplify: ["Config management"],
            accelerate: ["CI pipeline"],
            automate: ["Runbook for DB failover"]
        ),
        dsaaFocusThisWeek: .simplify,
        aiTasks: [AiTask(task: "Code review assist", enabled: true, owner: "Team")],
        aiGuardrailsChecked: ["human_review", "no_prod_access"],
        timeBlocks: [
            "monday": DayTimeBlock(deepWork: "9-12", freeThinking: "14-15", reactiveBudget: "15-16", keyMeeting: "13-14"),
            "tuesday": DayTimeBlock(deepWork: "9-12", freeThinking: "14-15", reactiveBudget: "15-16", keyMeeting: "16-17")
        ],
        incidentChecklist: IncidentChecklist(
            p0p1Reviewed: true, postmortemScheduled: false, actionItemsOwned: true,
            runbooksUpdated: false, preventionBetChosen: false
        ),
        adrChecklist: AdrChecklist(
            adrLinkExists: true, alternativesConsidered: true, rolloutRollbackPlan: false,
            observabilityPlan: false, dataContractsChecked: false
        ),
        scorecard: nil,
        aiWeeklySummary: nil,
        aiCoachingNotes: nil,
        outcomes: [],
        decisions: [],
        createdAt: "2026-03-16T00:00:00Z",
        updatedAt: "2026-03-16T00:00:00Z",
        completedAt: nil
    )
}
