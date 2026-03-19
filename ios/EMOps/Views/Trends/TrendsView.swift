import SwiftUI
import Charts

struct TrendsView: View {
    @StateObject var viewModel = TrendsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Period selector
                    Picker("Period", selection: $viewModel.selectedPeriod) {
                        ForEach(TrendPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue.capitalized).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.selectedPeriod) { _ in
                        Task {
                            await viewModel.loadTrends()
                        }
                    }

                    // Deep Work Chart
                    if !viewModel.weeklyTrends.isEmpty {
                        DeepWorkChart(trends: viewModel.weeklyTrends)
                    }

                    // Habit Completion Chart
                    if !viewModel.weeklyTrends.isEmpty {
                        HabitCompletionChart(trends: viewModel.weeklyTrends)
                    }

                    // DSAA Distribution Chart
                    if !viewModel.weeklyTrends.isEmpty {
                        DsaaDistributionChart(trends: viewModel.weeklyTrends)
                    }

                    // Outcome Tracker
                    if !viewModel.weeklyTrends.isEmpty {
                        OutcomeTracker(trends: viewModel.weeklyTrends)
                    }

                    // AI Trend Insight
                    if let insight = viewModel.aiTrendInsight {
                        aiInsightCard(insight: insight)
                    } else {
                        Button {
                            Task {
                                await viewModel.requestAiInsight()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                Text("Get AI Trend Insight")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: 0x6C8CFF))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(hex: 0x6C8CFF).opacity(0.12))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color(hex: 0x0F1117).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Trends")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                }
            }
            .overlay {
                if viewModel.isLoading && viewModel.weeklyTrends.isEmpty {
                    ProgressView()
                        .tint(Color(hex: 0x6C8CFF))
                }
            }
        }
        .task {
            await viewModel.loadTrends()
        }
    }

    // MARK: - AI Insight Card

    private func aiInsightCard(insight: String) -> some View {
        AiInsightCard(title: "Trend Insight", content: insight)
    }
}

#Preview {
    TrendsView()
}
