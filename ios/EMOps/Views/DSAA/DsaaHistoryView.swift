import SwiftUI

struct DsaaHistoryView: View {
    @StateObject private var viewModel = DsaaViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.history.isEmpty && !viewModel.isLoading {
                    emptyState
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.history) { log in
                            historyRow(log: log)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .background(Color(hex: 0x0F1117).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("DSAA History")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: 0x6C8CFF))
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(Color(hex: 0x6C8CFF))
                }
            }
        }
        .task {
            await viewModel.loadHistory()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: 0x8B95A8).opacity(0.5))
            Text("No DSAA rituals yet")
                .font(.headline)
                .foregroundColor(Color(hex: 0x8B95A8))
            Text("Complete your first ritual to see it here")
                .font(.subheadline)
                .foregroundColor(Color(hex: 0x8B95A8).opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: - History Row

    private func historyRow(log: DsaaLog) -> some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(formattedDate(log.logDate))
                        .font(.caption)
                        .foregroundColor(Color(hex: 0x8B95A8))
                    Spacer()
                    dsaaActionBadge(log.dsaaAction)
                }

                Text(log.frictionPoint)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: 0xE8ECF4))

                if !log.microArtifactDescription.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text.fill")
                            .font(.caption2)
                            .foregroundColor(Color(hex: 0x8B95A8))
                        Text(log.microArtifactDescription)
                            .font(.caption)
                            .foregroundColor(Color(hex: 0x8B95A8))
                            .lineLimit(2)
                    }
                }

                if let duration = log.durationMinutes {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(Color(hex: 0x8B95A8).opacity(0.7))
                        Text("\(duration) min")
                            .font(.caption2)
                            .foregroundColor(Color(hex: 0x8B95A8).opacity(0.7))
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func dsaaActionBadge(_ action: DsaaLog.DsaaAction) -> some View {
        let color = dsaaColor(action)
        return Text(action.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }

    private func dsaaColor(_ action: DsaaLog.DsaaAction) -> Color {
        switch action {
        case .delete: return Color(hex: 0xFF6B6B)
        case .simplify: return Color(hex: 0xFFB84D)
        case .accelerate: return Color(hex: 0x6C8CFF)
        case .automate: return Color(hex: 0x00D4AA)
        }
    }

    private func formattedDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = inputFormatter.date(from: dateString) else { return dateString }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy"
        return outputFormatter.string(from: date)
    }
}

#Preview {
    DsaaHistoryView()
}
