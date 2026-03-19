import SwiftUI

struct EMOpsCard<Content: View>: View {
    let title: String?
    @ViewBuilder let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = title {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "E8ECF4"))
            }

            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "1A1D27"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "0F1117").ignoresSafeArea()
        VStack(spacing: 16) {
            EMOpsCard(title: "Weekly Summary") {
                Text("You completed 85% of your habits this week.")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "8B95A8"))
            }

            EMOpsCard {
                HStack {
                    Text("No title card")
                        .foregroundColor(Color(hex: "E8ECF4"))
                    Spacer()
                    ProgressRing(progress: 0.72, size: 44, foregroundColor: Color(hex: "00D4AA"))
                }
            }
        }
        .padding()
    }
}
