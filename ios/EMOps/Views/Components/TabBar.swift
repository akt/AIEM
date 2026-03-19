import SwiftUI

struct TabBar: View {
    @Binding var selectedTab: Int

    private let primaryColor = Color(hex: "6C8CFF")
    private let unselectedColor = Color(hex: "8B95A8")
    private let backgroundColor = Color(hex: "1A1D27")

    private let tabs: [(icon: String, label: String)] = [
        ("house", "Home"),
        ("doc.text", "Sheet"),
        ("checkmark.circle", "Habits"),
        ("chart.line.uptrend.xyaxis", "Trends"),
        ("brain", "AI")
    ]

    var body: some View {
        HStack {
            ForEach(0..<tabs.count, id: \.self) { index in
                tabButton(index: index)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(backgroundColor)
    }

    @ViewBuilder
    private func tabButton(index: Int) -> some View {
        let isSelected = selectedTab == index
        let tab = tabs[index]

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.icon + ".fill" : tab.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? primaryColor : unselectedColor)
                    // Fall back to non-fill variant if fill doesn't exist
                    .symbolRenderingMode(.hierarchical)

                Text(tab.label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? primaryColor : unselectedColor)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "0F1117").ignoresSafeArea()
        VStack {
            Spacer()
            TabBar(selectedTab: .constant(0))
        }
    }
}
