import SwiftUI

struct DsaaQueueSection: View {
    let sheet: WeeklySheet

    @State private var deleteItems: [String] = []
    @State private var simplifyItems: [String] = []
    @State private var accelerateItems: [String] = []
    @State private var automateItems: [String] = []
    @State private var focusThisWeek: WeeklySheet.DsaaFocus = .delete

    var body: some View {
        VStack(spacing: 16) {
            // Focus Picker
            EMOpsCard {
                VStack(alignment: .leading, spacing: 10) {
                    sectionHeader(title: "DSAA Queue", icon: "arrow.triangle.2.circlepath")

                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("Focus This Week")
                        Picker("Focus", selection: $focusThisWeek) {
                            ForEach(WeeklySheet.DsaaFocus.allCases, id: \.self) { focus in
                                Text(focus.rawValue.capitalized).tag(focus)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Current focus indicator
                    HStack {
                        Spacer()
                        HStack(spacing: 6) {
                            Circle()
                                .fill(dsaaColor(focusThisWeek))
                                .frame(width: 10, height: 10)
                            Text("Focus: \(focusThisWeek.rawValue.capitalized)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(dsaaColor(focusThisWeek))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(dsaaColor(focusThisWeek).opacity(0.12))
                        .clipShape(Capsule())
                        Spacer()
                    }
                }
            }

            // Delete
            dsaaCategoryCard(
                title: "Delete",
                icon: "trash",
                color: Color(hex: 0xFF6B6B),
                items: $deleteItems
            )

            // Simplify
            dsaaCategoryCard(
                title: "Simplify",
                icon: "scissors",
                color: Color(hex: 0xFFB84D),
                items: $simplifyItems
            )

            // Accelerate
            dsaaCategoryCard(
                title: "Accelerate",
                icon: "hare",
                color: Color(hex: 0x6C8CFF),
                items: $accelerateItems
            )

            // Automate
            dsaaCategoryCard(
                title: "Automate",
                icon: "gearshape.2",
                color: Color(hex: 0x00D4AA),
                items: $automateItems
            )
        }
        .onAppear {
            deleteItems = sheet.dsaaQueue.delete
            simplifyItems = sheet.dsaaQueue.simplify
            accelerateItems = sheet.dsaaQueue.accelerate
            automateItems = sheet.dsaaQueue.automate
            focusThisWeek = sheet.dsaaFocusThisWeek
        }
    }

    private func dsaaCategoryCard(
        title: String,
        icon: String,
        color: Color,
        items: Binding<[String]>
    ) -> some View {
        EMOpsCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: icon)
                            .foregroundColor(color)
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(color)
                    }

                    Spacer()

                    Text("\(items.wrappedValue.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(color.opacity(0.15))
                        .clipShape(Capsule())

                    Button {
                        items.wrappedValue.append("")
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundColor(color)
                    }
                }

                ForEach(Array(items.wrappedValue.enumerated()), id: \.offset) { index, _ in
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color)
                            .frame(width: 3, height: 24)

                        TextField("Item \(index + 1)", text: items[index])
                            .font(.subheadline)
                            .foregroundColor(Color(hex: 0xE8ECF4))
                            .padding(8)
                            .background(Color(hex: 0x242836))
                            .cornerRadius(6)

                        Button {
                            items.wrappedValue.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle")
                                .foregroundColor(Color(hex: 0xFF6B6B).opacity(0.7))
                                .font(.caption)
                        }
                    }
                }

                if items.wrappedValue.isEmpty {
                    Text("No items yet")
                        .font(.caption)
                        .foregroundColor(Color(hex: 0x8B95A8))
                        .italic()
                        .padding(.vertical, 4)
                }
            }
        }
    }

    private func dsaaColor(_ focus: WeeklySheet.DsaaFocus) -> Color {
        switch focus {
        case .delete: return Color(hex: 0xFF6B6B)
        case .simplify: return Color(hex: 0xFFB84D)
        case .accelerate: return Color(hex: 0x6C8CFF)
        case .automate: return Color(hex: 0x00D4AA)
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

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(Color(hex: 0x8B95A8))
            .textCase(.uppercase)
    }
}

#Preview {
    ScrollView {
        DsaaQueueSection(sheet: PreviewData.sampleSheet)
            .padding()
    }
    .background(Color(hex: 0x0F1117))
}
