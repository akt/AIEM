import SwiftUI

struct ConstraintSection: View {
    let sheet: WeeklySheet

    @State private var constraintStatement: String = ""
    @State private var sliDashboards: String = ""
    @State private var incidentPattern: String = ""
    @State private var queueLag: String = ""
    @State private var costRegression: String = ""
    @State private var sloService: String = ""
    @State private var sloTargets: String = ""
    @State private var errorBudgetStatus: WeeklySheet.ErrorBudgetStatus = .healthy
    @State private var exhaustedAction: String = ""

    var body: some View {
        VStack(spacing: 16) {
            // Constraint Statement
            EMOpsCard {
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader(title: "Constraint", icon: "exclamationmark.triangle")

                    fieldGroup(label: "Constraint Statement") {
                        TextEditor(text: $constraintStatement)
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

            // Evidence
            EMOpsCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Constraint Evidence")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0xE8ECF4))

                    evidenceField(label: "SLI Dashboards", text: $sliDashboards)
                    evidenceField(label: "Incident Pattern", text: $incidentPattern)
                    evidenceField(label: "Queue Lag", text: $queueLag)
                    evidenceField(label: "Cost Regression", text: $costRegression)
                }
            }

            // SLO & Error Budget
            EMOpsCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("SLO & Error Budget")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0xE8ECF4))

                    fieldGroup(label: "SLO Service") {
                        TextField("Service name", text: $sloService)
                            .font(.subheadline)
                            .foregroundColor(Color(hex: 0xE8ECF4))
                            .padding(10)
                            .background(Color(hex: 0x242836))
                            .cornerRadius(8)
                    }

                    fieldGroup(label: "SLO Targets") {
                        TextField("e.g., 99.9% availability", text: $sloTargets)
                            .font(.subheadline)
                            .foregroundColor(Color(hex: 0xE8ECF4))
                            .padding(10)
                            .background(Color(hex: 0x242836))
                            .cornerRadius(8)
                    }

                    // Error Budget Status Picker
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("Error Budget Status")
                        Picker("Error Budget Status", selection: $errorBudgetStatus) {
                            ForEach(WeeklySheet.ErrorBudgetStatus.allCases, id: \.self) { status in
                                HStack {
                                    Circle()
                                        .fill(budgetColor(status))
                                        .frame(width: 8, height: 8)
                                    Text(status.rawValue.capitalized)
                                }
                                .tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                        .colorMultiply(budgetColor(errorBudgetStatus))
                    }

                    // Budget status badge
                    HStack {
                        Spacer()
                        Text(errorBudgetStatus.rawValue.capitalized)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(budgetColor(errorBudgetStatus))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(budgetColor(errorBudgetStatus).opacity(0.15))
                            .clipShape(Capsule())
                        Spacer()
                    }

                    // Exhausted Action
                    fieldGroup(label: "Exhausted Action") {
                        TextField("Action if budget exhausted", text: $exhaustedAction)
                            .font(.subheadline)
                            .foregroundColor(Color(hex: 0xE8ECF4))
                            .padding(10)
                            .background(Color(hex: 0x242836))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .onAppear {
            constraintStatement = sheet.constraintStatement
            sliDashboards = sheet.constraintEvidence.sliDashboards
            incidentPattern = sheet.constraintEvidence.incidentPattern
            queueLag = sheet.constraintEvidence.queueLag
            costRegression = sheet.constraintEvidence.costRegression
            sloService = sheet.constraintSloService
            sloTargets = sheet.constraintSloTargets
            errorBudgetStatus = sheet.constraintErrorBudgetStatus
            exhaustedAction = sheet.constraintExhaustedAction
        }
    }

    private func evidenceField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            fieldLabel(label)
            TextField(label, text: text)
                .font(.subheadline)
                .foregroundColor(Color(hex: 0xE8ECF4))
                .padding(10)
                .background(Color(hex: 0x242836))
                .cornerRadius(8)
        }
    }

    private func fieldGroup(label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel(label)
            content()
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
                .foregroundColor(Color(hex: 0xFFB84D))
            Text(title)
                .font(.headline)
                .foregroundColor(Color(hex: 0xE8ECF4))
        }
    }

    private func budgetColor(_ status: WeeklySheet.ErrorBudgetStatus) -> Color {
        switch status {
        case .healthy: return Color(hex: 0x00D4AA)
        case .burning: return Color(hex: 0xFFB84D)
        case .exhausted: return Color(hex: 0xFF6B6B)
        }
    }
}

#Preview {
    ScrollView {
        ConstraintSection(sheet: PreviewData.sampleSheet)
            .padding()
    }
    .background(Color(hex: 0x0F1117))
}
