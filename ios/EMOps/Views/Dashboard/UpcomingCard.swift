import SwiftUI

struct UpcomingCard: View {
    let reminders: [Reminder]

    var body: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(Color(hex: 0xFFB84D))
                    Text("Upcoming")
                        .font(.headline)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                }

                ForEach(reminders) { reminder in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color(hex: 0x6C8CFF))
                            .frame(width: 8, height: 8)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(reminder.title)
                                .font(.subheadline)
                                .foregroundColor(Color(hex: 0xE8ECF4))
                                .lineLimit(1)
                            if !reminder.body.isEmpty {
                                Text(reminder.body)
                                    .font(.caption)
                                    .foregroundColor(Color(hex: 0x8B95A8))
                                    .lineLimit(1)
                            }
                        }

                        Spacer()

                        Text(formatTime(reminder.scheduledAt))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: 0x8B95A8))
                    }

                    if reminder.id != reminders.last?.id {
                        Divider()
                            .background(Color(hex: 0x242836))
                    }
                }
            }
        }
    }

    private func formatTime(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: isoString) else {
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: isoString) else { return isoString }
            return timeString(from: date)
        }
        return timeString(from: date)
    }

    private func timeString(from date: Date) -> String {
        let display = DateFormatter()
        display.dateFormat = "h:mm a"
        return display.string(from: date)
    }
}

#Preview {
    UpcomingCard(reminders: [])
        .padding()
        .background(Color(hex: 0x0F1117))
}
