import SwiftUI

struct WeeklySheetView: View {
    @StateObject var viewModel = WeeklySheetViewModel()

    private let tabs = [
        "Identity", "Outcomes", "Constraint", "DSAA", "AI", "Calendar", "Score"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab selector
                tabBar

                // Tab content
                if viewModel.isLoading && viewModel.sheet == nil {
                    Spacer()
                    ProgressView()
                        .tint(Color(hex: 0x6C8CFF))
                    Spacer()
                } else if let sheet = viewModel.sheet {
                    ScrollView {
                        VStack(spacing: 16) {
                            tabContent(sheet: sheet)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                } else {
                    Spacer()
                    Text("No weekly sheet available")
                        .foregroundColor(Color(hex: 0x8B95A8))
                    Spacer()
                }

                // Bottom quick actions
                if viewModel.sheet != nil {
                    quickActions
                }
            }
            .background(Color(hex: 0x0F1117).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(viewModel.sheet?.weekLabel ?? "Weekly Sheet")
                        .font(.headline)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                }
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.error ?? "")
            }
        }
        .task {
            await viewModel.loadCurrentSheet()
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedTab = index
                        }
                    } label: {
                        Text(tab)
                            .font(.subheadline)
                            .fontWeight(viewModel.selectedTab == index ? .semibold : .regular)
                            .foregroundColor(
                                viewModel.selectedTab == index
                                    ? Color(hex: 0x6C8CFF)
                                    : Color(hex: 0x8B95A8)
                            )
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedTab == index
                                    ? Color(hex: 0x6C8CFF).opacity(0.12)
                                    : Color.clear
                            )
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(hex: 0x1A1D27))
    }

    // MARK: - Tab Content

    @ViewBuilder
    private func tabContent(sheet: WeeklySheet) -> some View {
        switch viewModel.selectedTab {
        case 0:
            IdentitySection(sheet: sheet)
        case 1:
            OutcomesSection(
                outcomes: $viewModel.outcomes,
                onAdd: { text, impact, dod, owner, risk in
                    Task { await viewModel.addOutcome(text: text, impact: impact, dod: dod, owner: owner, risk: risk) }
                },
                onDelete: { id in
                    Task { await viewModel.deleteOutcome(id: id) }
                },
                onStatusChange: { id, status in
                    Task { await viewModel.updateOutcomeStatus(id: id, status: status) }
                }
            )
        case 2:
            ConstraintSection(sheet: sheet)
        case 3:
            DsaaQueueSection(sheet: sheet)
        case 4:
            AiPlanSection(sheet: sheet)
        case 5:
            VStack(spacing: 16) {
                TimeBlocksSection(sheet: sheet)
                IncidentSection(sheet: sheet)
                AdrSection(sheet: sheet)
            }
        case 6:
            ScorecardSection(sheet: sheet)
        default:
            EmptyView()
        }
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                quickActionButton(title: "Fill from Last Week", icon: "doc.on.doc") {
                    // Placeholder: would load previous week data
                }

                quickActionButton(title: "Carry Forward", icon: "arrow.uturn.forward") {
                    Task { await viewModel.carryForward() }
                }

                quickActionButton(title: "AI Summary", icon: "sparkles") {
                    Task { await viewModel.generateSummary() }
                }

                quickActionButton(title: "Complete Week", icon: "checkmark.seal") {
                    Task { await viewModel.completeSheet() }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color(hex: 0x1A1D27))
    }

    private func quickActionButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(Color(hex: 0x6C8CFF))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(hex: 0x242836))
            .cornerRadius(8)
        }
    }
}

#Preview {
    WeeklySheetView()
}
