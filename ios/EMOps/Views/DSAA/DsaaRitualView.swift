import SwiftUI

struct DsaaRitualView: View {
    @StateObject var viewModel = DsaaViewModel()
    @State private var showingHistory = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Timer display
                    DsaaTimerView(
                        secondsRemaining: viewModel.timerSecondsRemaining,
                        isRunning: viewModel.isTimerRunning,
                        onStartStop: {
                            if viewModel.isTimerRunning {
                                viewModel.stopTimer()
                            } else {
                                viewModel.startTimer()
                            }
                        }
                    )

                    // Already completed today
                    if let log = viewModel.todayLog {
                        completedCard(log: log)
                    } else {
                        // AI Suggestion card
                        if let suggestion = viewModel.aiSuggestion {
                            DsaaSuggestionCard(
                                suggestion: suggestion,
                                onAccept: {
                                    viewModel.acceptSuggestion()
                                },
                                onModify: {
                                    viewModel.acceptSuggestion()
                                },
                                onSkip: {
                                    viewModel.aiSuggestion = nil
                                }
                            )
                        }

                        // Divider
                        dividerSection

                        // Manual form
                        formSection

                        // Start timer button
                        if !viewModel.isTimerRunning {
                            Button {
                                viewModel.startTimer()
                            } label: {
                                HStack {
                                    Image(systemName: "timer")
                                    Text("Start 15-Min Timer")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: 0x0F1117))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(hex: 0x6C8CFF))
                                .cornerRadius(12)
                            }
                        }

                        // Save button
                        Button {
                            Task {
                                await viewModel.saveDsaaLog()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Save & Complete Ritual")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: 0x0F1117))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(hex: 0x00D4AA))
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.frictionPoint.isEmpty)
                        .opacity(viewModel.frictionPoint.isEmpty ? 0.5 : 1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color(hex: 0x0F1117).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("DSAA Ritual")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingHistory = true
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(Color(hex: 0x8B95A8))
                    }
                }
            }
            .sheet(isPresented: $showingHistory) {
                DsaaHistoryView()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(Color(hex: 0x6C8CFF))
                }
            }
        }
        .task {
            await viewModel.loadToday()
            await viewModel.fetchAiSuggestion()
        }
    }

    // MARK: - Completed Card

    private func completedCard(log: DsaaLog) -> some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(Color(hex: 0x00D4AA))
                    Text("Today's Ritual Complete")
                        .font(.headline)
                        .foregroundColor(Color(hex: 0x00D4AA))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Friction Point")
                        .font(.caption)
                        .foregroundColor(Color(hex: 0x8B95A8))
                    Text(log.frictionPoint)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                }

                HStack(spacing: 8) {
                    dsaaActionBadge(log.dsaaAction)
                    if let duration = log.durationMinutes {
                        Text("\(duration) min")
                            .font(.caption)
                            .foregroundColor(Color(hex: 0x8B95A8))
                    }
                }
            }
        }
    }

    // MARK: - Divider

    private var dividerSection: some View {
        HStack {
            Rectangle()
                .fill(Color(hex: 0x242836))
                .frame(height: 1)
            Text("OR CHOOSE YOUR OWN")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: 0x8B95A8))
                .tracking(1)
            Rectangle()
                .fill(Color(hex: 0x242836))
                .frame(height: 1)
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: 16) {
            // Friction Point
            VStack(alignment: .leading, spacing: 6) {
                Text("Friction Point")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: 0x8B95A8))
                TextField("What's slowing you down?", text: $viewModel.frictionPoint)
                    .textFieldStyle(EMOpsTextFieldStyle())
            }

            // DSAA Action
            VStack(alignment: .leading, spacing: 6) {
                Text("DSAA Action")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: 0x8B95A8))

                HStack(spacing: 0) {
                    ForEach(DsaaLog.DsaaAction.allCases, id: \.self) { action in
                        Button {
                            viewModel.selectedAction = action
                        } label: {
                            Text(action.rawValue.prefix(1).uppercased())
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(
                                    viewModel.selectedAction == action
                                        ? Color(hex: 0x0F1117)
                                        : dsaaColor(action)
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    viewModel.selectedAction == action
                                        ? dsaaColor(action)
                                        : dsaaColor(action).opacity(0.12)
                                )
                        }
                    }
                }
                .cornerRadius(10)

                // Selected action label
                Text(viewModel.selectedAction.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(dsaaColor(viewModel.selectedAction))
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            // Micro-Artifact Type
            VStack(alignment: .leading, spacing: 6) {
                Text("Micro-Artifact Type")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: 0x8B95A8))
                TextField("e.g., script, runbook, config", text: $viewModel.microArtifactType)
                    .textFieldStyle(EMOpsTextFieldStyle())
            }

            // Micro-Artifact Description
            VStack(alignment: .leading, spacing: 6) {
                Text("Micro-Artifact Description")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: 0x8B95A8))
                TextField("What did you produce?", text: $viewModel.microArtifactDescription, axis: .vertical)
                    .lineLimit(2...4)
                    .textFieldStyle(EMOpsTextFieldStyle())
            }

            // Expected Leverage
            VStack(alignment: .leading, spacing: 6) {
                Text("Expected Leverage")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: 0x8B95A8))
                TextField("How much time/effort will this save?", text: $viewModel.expectedLeverage)
                    .textFieldStyle(EMOpsTextFieldStyle())
            }
        }
    }

    // MARK: - Helpers

    private func dsaaColor(_ action: DsaaLog.DsaaAction) -> Color {
        switch action {
        case .delete: return Color(hex: 0xFF6B6B)
        case .simplify: return Color(hex: 0xFFB84D)
        case .accelerate: return Color(hex: 0x6C8CFF)
        case .automate: return Color(hex: 0x00D4AA)
        }
    }

    private func dsaaActionBadge(_ action: DsaaLog.DsaaAction) -> some View {
        Text(action.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(dsaaColor(action))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(dsaaColor(action).opacity(0.15))
            .clipShape(Capsule())
    }
}

#Preview {
    DsaaRitualView()
}
