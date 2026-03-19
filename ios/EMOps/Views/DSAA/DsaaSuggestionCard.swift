import SwiftUI

struct DsaaSuggestionCard: View {
    let suggestion: AiSuggestionResponse
    let onAccept: () -> Void
    let onModify: () -> Void
    let onSkip: () -> Void

    var body: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(Color(hex: 0x6C8CFF))
                    Text("AI Suggestion")
                        .font(.headline)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                    Spacer()
                    actionBadge
                }

                // Description
                Text(suggestion.suggestion)
                    .font(.subheadline)
                    .foregroundColor(Color(hex: 0xE8ECF4))

                // Reasoning
                if !suggestion.reasoning.isEmpty {
                    Text(suggestion.reasoning)
                        .font(.caption)
                        .foregroundColor(Color(hex: 0x8B95A8))
                        .italic()
                }

                // Buttons
                HStack(spacing: 12) {
                    Button {
                        onAccept()
                    } label: {
                        Text("Accept")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: 0x0F1117))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(hex: 0x00D4AA))
                            .cornerRadius(8)
                    }

                    Button {
                        onModify()
                    } label: {
                        Text("Modify")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: 0x6C8CFF))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(hex: 0x6C8CFF).opacity(0.15))
                            .cornerRadius(8)
                    }

                    Button {
                        onSkip()
                    } label: {
                        Text("Skip")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: 0x8B95A8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(hex: 0x242836))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }

    private var actionBadge: some View {
        let action = suggestion.suggestedAction.lowercased()
        let color: Color = {
            switch action {
            case "delete": return Color(hex: 0xFF6B6B)
            case "simplify": return Color(hex: 0xFFB84D)
            case "accelerate": return Color(hex: 0x6C8CFF)
            case "automate": return Color(hex: 0x00D4AA)
            default: return Color(hex: 0x6C8CFF)
            }
        }()

        return Text(suggestion.suggestedAction.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}

#Preview {
    ZStack {
        Color(hex: 0x0F1117).ignoresSafeArea()
        DsaaSuggestionCard(
            suggestion: AiSuggestionResponse(
                suggestion: "Automate the weekly deployment checklist into a CI/CD pipeline step",
                suggestedAction: "automate",
                reasoning: "You've manually run this checklist 4 times in the past month"
            ),
            onAccept: {},
            onModify: {},
            onSkip: {}
        )
        .padding()
    }
}
