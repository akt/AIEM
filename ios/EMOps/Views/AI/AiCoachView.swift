import SwiftUI

struct AiCoachView: View {
    @StateObject var viewModel = AiCoachViewModel()
    @State private var inputText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if viewModel.messages.isEmpty && !viewModel.isLoading {
                                welcomeMessage
                            }

                            ForEach(viewModel.messages) { message in
                                messageBubble(message)
                                    .id(message.id)
                            }

                            if viewModel.isLoading {
                                HStack {
                                    typingIndicator
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .id("loading")
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Quick action buttons
                quickActions

                // Input field
                inputSection
            }
            .background(Color(hex: 0x0F1117).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(Color(hex: 0x6C8CFF))
                        Text("AI Coach")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: 0xE8ECF4))
                    }
                }
            }
        }
    }

    // MARK: - Welcome Message

    private var welcomeMessage: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: 0x6C8CFF).opacity(0.5))

            Text("Your AI Engineering Coach")
                .font(.headline)
                .foregroundColor(Color(hex: 0xE8ECF4))

            Text("Get daily coaching, weekly summaries, constraint analysis, and trend insights to level up your engineering management.")
                .font(.subheadline)
                .foregroundColor(Color(hex: 0x8B95A8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Message Bubble

    private func messageBubble(_ message: AiCoachViewModel.CoachMessage) -> some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isFromAi {
                // AI avatar
                Circle()
                    .fill(Color(hex: 0x6C8CFF).opacity(0.2))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "brain.head.profile")
                            .font(.caption)
                            .foregroundColor(Color(hex: 0x6C8CFF))
                    )
            } else {
                Spacer(minLength: 60)
            }

            VStack(alignment: message.isFromAi ? .leading : .trailing, spacing: 4) {
                Text(message.content)
                    .font(.subheadline)
                    .foregroundColor(Color(hex: 0xE8ECF4))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.isFromAi
                            ? Color(hex: 0x1A1D27)
                            : Color(hex: 0x6C8CFF).opacity(0.2)
                    )
                    .cornerRadius(16)

                Text(timeString(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(Color(hex: 0x8B95A8).opacity(0.6))
            }

            if !message.isFromAi {
                // User avatar placeholder
                Circle()
                    .fill(Color(hex: 0x00D4AA).opacity(0.2))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundColor(Color(hex: 0x00D4AA))
                    )
            } else {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Typing Indicator

    private var typingIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color(hex: 0x6C8CFF).opacity(0.2))
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "brain.head.profile")
                        .font(.caption)
                        .foregroundColor(Color(hex: 0x6C8CFF))
                )

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(Color(hex: 0x8B95A8))
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(hex: 0x1A1D27))
            .cornerRadius(16)
        }
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                quickActionButton(title: "Daily Coaching", icon: "sun.max") {
                    Task { await viewModel.loadDailyCoaching() }
                }
                quickActionButton(title: "Weekly Summary", icon: "calendar") {
                    Task { await viewModel.getWeeklySummary() }
                }
                quickActionButton(title: "Constraint Analysis", icon: "target") {
                    Task { await viewModel.analyzeConstraint() }
                }
                quickActionButton(title: "Trend Insight", icon: "chart.line.uptrend.xyaxis") {
                    Task { await viewModel.getTrendInsight() }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(hex: 0x1A1D27).opacity(0.5))
    }

    private func quickActionButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(Color(hex: 0x6C8CFF))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(hex: 0x6C8CFF).opacity(0.12))
            .cornerRadius(20)
        }
        .disabled(viewModel.isLoading)
    }

    // MARK: - Input Section

    private var inputSection: some View {
        HStack(spacing: 12) {
            TextField("Ask your AI coach...", text: $inputText)
                .textFieldStyle(EMOpsTextFieldStyle())

            Button {
                let text = inputText
                inputText = ""
                Task { await viewModel.sendMessage(text) }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(
                        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color(hex: 0x8B95A8)
                            : Color(hex: 0x6C8CFF)
                    )
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: 0x1A1D27))
    }

    // MARK: - Helpers

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    AiCoachView()
}
