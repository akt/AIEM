import SwiftUI

struct ErrorBudgetIndicator: View {
    let status: String

    private var statusColor: Color {
        switch status.lowercased() {
        case "healthy":
            return Color(hex: "00D4AA")
        case "burning":
            return Color(hex: "FFB84D")
        case "exhausted":
            return Color(hex: "FF6B6B")
        default:
            return Color(hex: "8B95A8")
        }
    }

    private var displayText: String {
        status.uppercased()
    }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(displayText)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(statusColor.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "0F1117").ignoresSafeArea()
        VStack(spacing: 12) {
            ErrorBudgetIndicator(status: "healthy")
            ErrorBudgetIndicator(status: "burning")
            ErrorBudgetIndicator(status: "exhausted")
        }
    }
}
