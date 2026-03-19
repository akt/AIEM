import SwiftUI

struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 8
    var size: CGFloat = 60
    var foregroundColor: Color = Color(hex: "6C8CFF")

    private let backgroundColor = Color(hex: "242836")

    @State private var animatedProgress: Double = 0

    private var percentage: Int {
        Int(animatedProgress * 100)
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            // Foreground ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    foregroundColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Percentage text
            Text("\(percentage)%")
                .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "E8ECF4"))
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedProgress = clampedProgress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = min(max(newValue, 0), 1)
            }
        }
    }

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "0F1117").ignoresSafeArea()
        HStack(spacing: 20) {
            ProgressRing(progress: 0.25, size: 60)
            ProgressRing(progress: 0.65, size: 80, foregroundColor: Color(hex: "00D4AA"))
            ProgressRing(progress: 0.9, lineWidth: 10, size: 100, foregroundColor: Color(hex: "FFB84D"))
        }
    }
}
