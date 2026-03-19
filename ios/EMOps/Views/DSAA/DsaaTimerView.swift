import SwiftUI

struct DsaaTimerView: View {
    let secondsRemaining: Int
    let isRunning: Bool
    let onStartStop: () -> Void

    private var progress: Double {
        1.0 - Double(secondsRemaining) / 900.0
    }

    private var timeString: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color(hex: 0x242836), lineWidth: 8)
                    .frame(width: 160, height: 160)

                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        ringColor,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                // Time display
                VStack(spacing: 4) {
                    Text(timeString)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: 0xE8ECF4))
                    Text(isRunning ? "In Progress" : "15 Minutes")
                        .font(.caption)
                        .foregroundColor(Color(hex: 0x8B95A8))
                }
            }

            // Start/Stop button
            Button {
                onStartStop()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isRunning ? "stop.fill" : "play.fill")
                        .font(.caption)
                    Text(isRunning ? "Stop" : "Start")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(isRunning ? Color(hex: 0xFF6B6B) : Color(hex: 0x00D4AA))
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(
                    (isRunning ? Color(hex: 0xFF6B6B) : Color(hex: 0x00D4AA)).opacity(0.15)
                )
                .cornerRadius(20)
            }
        }
        .padding(.vertical, 8)
    }

    private var ringColor: Color {
        if secondsRemaining <= 60 {
            return Color(hex: 0xFF6B6B)
        } else if secondsRemaining <= 300 {
            return Color(hex: 0xFFB84D)
        } else {
            return Color(hex: 0x6C8CFF)
        }
    }
}

#Preview {
    ZStack {
        Color(hex: 0x0F1117).ignoresSafeArea()
        VStack(spacing: 40) {
            DsaaTimerView(secondsRemaining: 900, isRunning: false, onStartStop: {})
            DsaaTimerView(secondsRemaining: 420, isRunning: true, onStartStop: {})
        }
    }
}
