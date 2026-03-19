import SwiftUI

struct StreakBadge: View {
    let count: Int

    private let badgeColor = Color(hex: "FFB84D")

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(badgeColor)

            Text("\(count) days")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(badgeColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(badgeColor.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "0F1117").ignoresSafeArea()
        VStack(spacing: 12) {
            StreakBadge(count: 14)
            StreakBadge(count: 3)
            StreakBadge(count: 100)
        }
    }
}
