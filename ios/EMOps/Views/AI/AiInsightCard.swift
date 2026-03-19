import SwiftUI

struct AiInsightCard: View {
    let title: String
    let content: String

    var body: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(Color(hex: 0x6C8CFF))
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                    Spacer()
                    poweredByBadge
                }

                Text(content)
                    .font(.subheadline)
                    .foregroundColor(Color(hex: 0x8B95A8))
                    .lineSpacing(4)
            }
        }
    }

    private var poweredByBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.caption2)
            Text("Powered by AI")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(Color(hex: 0x6C8CFF).opacity(0.7))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(hex: 0x6C8CFF).opacity(0.1))
        .clipShape(Capsule())
    }
}

#Preview {
    ZStack {
        Color(hex: 0x0F1117).ignoresSafeArea()
        AiInsightCard(
            title: "Weekly Insight",
            content: "Your deep work hours increased by 15% this week compared to last week. Consider maintaining this momentum by protecting your morning focus blocks. Your DSAA ritual streak of 5 days is building a strong habit loop."
        )
        .padding()
    }
}
