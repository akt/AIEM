import SwiftUI

struct TimeBlocksSection: View {
    let sheet: WeeklySheet

    private let weekdays = ["monday", "tuesday", "wednesday", "thursday", "friday"]
    private let weekdayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri"]

    @State private var timeBlocks: [String: EditableDayBlock] = [:]

    var body: some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(title: "Calendar & Time Blocks", icon: "calendar")

                ForEach(Array(zip(weekdays, weekdayLabels)), id: \.0) { day, label in
                    dayBlockRow(day: day, label: label)
                }
            }
        }
        .onAppear {
            for day in weekdays {
                if let block = sheet.timeBlocks[day] {
                    timeBlocks[day] = EditableDayBlock(
                        deepWork: block.deepWork,
                        freeThinking: block.freeThinking,
                        reactiveBudget: block.reactiveBudget,
                        keyMeeting: block.keyMeeting
                    )
                } else {
                    timeBlocks[day] = EditableDayBlock(
                        deepWork: "",
                        freeThinking: "",
                        reactiveBudget: "",
                        keyMeeting: ""
                    )
                }
            }
        }
    }

    private func dayBlockRow(day: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: 0x6C8CFF))

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 6) {
                timeField(
                    label: "Deep Work",
                    color: Color(hex: 0x6C8CFF),
                    text: Binding(
                        get: { timeBlocks[day]?.deepWork ?? "" },
                        set: { timeBlocks[day]?.deepWork = $0 }
                    )
                )
                timeField(
                    label: "Free Think",
                    color: Color(hex: 0x00D4AA),
                    text: Binding(
                        get: { timeBlocks[day]?.freeThinking ?? "" },
                        set: { timeBlocks[day]?.freeThinking = $0 }
                    )
                )
                timeField(
                    label: "Reactive",
                    color: Color(hex: 0xFFB84D),
                    text: Binding(
                        get: { timeBlocks[day]?.reactiveBudget ?? "" },
                        set: { timeBlocks[day]?.reactiveBudget = $0 }
                    )
                )
                timeField(
                    label: "Key Meeting",
                    color: Color(hex: 0x8B95A8),
                    text: Binding(
                        get: { timeBlocks[day]?.keyMeeting ?? "" },
                        set: { timeBlocks[day]?.keyMeeting = $0 }
                    )
                )
            }

            if day != weekdays.last {
                Divider()
                    .background(Color(hex: 0x242836))
                    .padding(.top, 4)
            }
        }
    }

    private func timeField(label: String, color: Color, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(Color(hex: 0x8B95A8))
            }
            TextField("e.g. 9-12", text: text)
                .font(.caption)
                .foregroundColor(Color(hex: 0xE8ECF4))
                .padding(6)
                .background(Color(hex: 0x242836))
                .cornerRadius(4)
        }
    }

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: 0x6C8CFF))
            Text(title)
                .font(.headline)
                .foregroundColor(Color(hex: 0xE8ECF4))
        }
    }
}

struct EditableDayBlock {
    var deepWork: String
    var freeThinking: String
    var reactiveBudget: String
    var keyMeeting: String
}

#Preview {
    ScrollView {
        TimeBlocksSection(sheet: PreviewData.sampleSheet)
            .padding()
    }
    .background(Color(hex: 0x0F1117))
}
