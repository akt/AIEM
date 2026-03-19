import SwiftUI

struct AiPlanSection: View {
    let sheet: WeeklySheet

    @State private var aiTasks: [EditableAiTask] = []
    @State private var guardrails: [GuardrailItem] = []

    private static let defaultGuardrails: [String] = [
        "human_review",
        "no_prod_access",
        "audit_logging",
        "rate_limited",
        "rollback_plan"
    ]

    var body: some View {
        VStack(spacing: 16) {
            // AI Tasks
            EMOpsCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        sectionHeader(title: "AI Plan", icon: "sparkles")
                        Spacer()
                        Button {
                            aiTasks.append(EditableAiTask(task: "", enabled: true, owner: ""))
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Task")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(Color(hex: 0x6C8CFF))
                        }
                    }

                    if aiTasks.isEmpty {
                        Text("No AI tasks planned")
                            .font(.caption)
                            .foregroundColor(Color(hex: 0x8B95A8))
                            .italic()
                            .padding(.vertical, 8)
                    }

                    ForEach(Array(aiTasks.enumerated()), id: \.element.id) { index, _ in
                        aiTaskRow(index: index)
                    }
                }
            }

            // Guardrails Checklist
            EMOpsCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "shield.checkered")
                            .foregroundColor(Color(hex: 0xFFB84D))
                        Text("AI Guardrails")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: 0xE8ECF4))
                    }

                    ForEach(Array(guardrails.enumerated()), id: \.element.id) { index, item in
                        Toggle(isOn: $guardrails[index].checked) {
                            Text(formatGuardrailLabel(item.name))
                                .font(.subheadline)
                                .foregroundColor(Color(hex: 0xE8ECF4))
                        }
                        .tint(Color(hex: 0x00D4AA))
                    }

                    // Completion summary
                    let checkedCount = guardrails.filter(\.checked).count
                    HStack {
                        Spacer()
                        Text("\(checkedCount)/\(guardrails.count) guardrails active")
                            .font(.caption)
                            .foregroundColor(
                                checkedCount == guardrails.count
                                    ? Color(hex: 0x00D4AA)
                                    : Color(hex: 0x8B95A8)
                            )
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            aiTasks = sheet.aiTasks.map { task in
                EditableAiTask(task: task.task, enabled: task.enabled, owner: task.owner)
            }
            guardrails = Self.defaultGuardrails.map { name in
                GuardrailItem(name: name, checked: sheet.aiGuardrailsChecked.contains(name))
            }
        }
    }

    private func aiTaskRow(index: Int) -> some View {
        VStack(spacing: 8) {
            HStack {
                Toggle("", isOn: $aiTasks[index].enabled)
                    .labelsHidden()
                    .tint(Color(hex: 0x6C8CFF))

                VStack(alignment: .leading, spacing: 4) {
                    TextField("Task name", text: $aiTasks[index].task)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                        .padding(8)
                        .background(Color(hex: 0x242836))
                        .cornerRadius(6)

                    TextField("Owner", text: $aiTasks[index].owner)
                        .font(.caption)
                        .foregroundColor(Color(hex: 0x8B95A8))
                        .padding(8)
                        .background(Color(hex: 0x242836))
                        .cornerRadius(6)
                }

                Button {
                    aiTasks.remove(at: index)
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(Color(hex: 0xFF6B6B))
                }
            }

            if index < aiTasks.count - 1 {
                Divider()
                    .background(Color(hex: 0x242836))
            }
        }
    }

    private func formatGuardrailLabel(_ name: String) -> String {
        name.replacingOccurrences(of: "_", with: " ").capitalized
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
}

// MARK: - Editable Models

struct EditableAiTask: Identifiable {
    let id = UUID()
    var task: String
    var enabled: Bool
    var owner: String
}

struct GuardrailItem: Identifiable {
    let id = UUID()
    let name: String
    var checked: Bool
}

#Preview {
    ScrollView {
        AiPlanSection(sheet: PreviewData.sampleSheet)
            .padding()
    }
    .background(Color(hex: 0x0F1117))
}
