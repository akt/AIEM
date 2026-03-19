import SwiftUI

struct HabitEditView: View {
    @Environment(\.dismiss) private var dismiss

    let habit: Habit?
    let onSave: (String, String, HabitCategory, Habit.Frequency, [String]?, Double, Habit.TargetUnit, String?, Bool) -> Void

    @State private var name: String
    @State private var description: String
    @State private var category: HabitCategory
    @State private var frequency: Habit.Frequency
    @State private var customDays: Set<String>
    @State private var targetValue: Double
    @State private var targetUnit: Habit.TargetUnit
    @State private var reminderTime: Date
    @State private var reminderEnabled: Bool

    private let allDays = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    init(habit: Habit?, onSave: @escaping (String, String, HabitCategory, Habit.Frequency, [String]?, Double, Habit.TargetUnit, String?, Bool) -> Void) {
        self.habit = habit
        self.onSave = onSave

        _name = State(initialValue: habit?.name ?? "")
        _description = State(initialValue: habit?.description ?? "")
        _category = State(initialValue: habit?.category ?? .deepWork)
        _frequency = State(initialValue: habit?.frequency ?? .daily)
        _customDays = State(initialValue: Set(habit?.customDays ?? []))
        _targetValue = State(initialValue: habit?.targetValue ?? 1)
        _targetUnit = State(initialValue: habit?.targetUnit ?? .boolean)
        _reminderEnabled = State(initialValue: habit?.reminderEnabled ?? false)

        if let timeString = habit?.reminderTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            _reminderTime = State(initialValue: formatter.date(from: timeString) ?? Date())
        } else {
            _reminderTime = State(initialValue: Date())
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Name
                    fieldSection(title: "Name") {
                        TextField("Habit name", text: $name)
                            .textFieldStyle(EMOpsTextFieldStyle())
                    }

                    // Description
                    fieldSection(title: "Description") {
                        TextField("What does this habit involve?", text: $description, axis: .vertical)
                            .lineLimit(3...6)
                            .textFieldStyle(EMOpsTextFieldStyle())
                    }

                    // Category
                    fieldSection(title: "Category") {
                        Picker("Category", selection: $category) {
                            ForEach(HabitCategory.allCases, id: \.self) { cat in
                                Text(cat.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .tag(cat)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Color(hex: 0x6C8CFF))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color(hex: 0x242836))
                        .cornerRadius(10)
                    }

                    // Frequency
                    fieldSection(title: "Frequency") {
                        Picker("Frequency", selection: $frequency) {
                            ForEach(Habit.Frequency.allCases, id: \.self) { freq in
                                Text(freq.rawValue.capitalized).tag(freq)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Custom Days (shown only when frequency is custom)
                    if frequency == .custom {
                        fieldSection(title: "Custom Days") {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                                ForEach(allDays, id: \.self) { day in
                                    let isSelected = customDays.contains(day)
                                    Button {
                                        if isSelected {
                                            customDays.remove(day)
                                        } else {
                                            customDays.insert(day)
                                        }
                                    } label: {
                                        Text(day.prefix(3).capitalized)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(isSelected ? Color(hex: 0x0F1117) : Color(hex: 0x8B95A8))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(isSelected ? Color(hex: 0x6C8CFF) : Color(hex: 0x242836))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }

                    // Target
                    HStack(spacing: 12) {
                        fieldSection(title: "Target Value") {
                            TextField("1", value: $targetValue, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(EMOpsTextFieldStyle())
                        }

                        fieldSection(title: "Unit") {
                            Picker("Unit", selection: $targetUnit) {
                                ForEach(Habit.TargetUnit.allCases, id: \.self) { unit in
                                    Text(unit.rawValue.capitalized).tag(unit)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color(hex: 0x6C8CFF))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color(hex: 0x242836))
                            .cornerRadius(10)
                        }
                    }

                    // Reminder
                    fieldSection(title: "Reminder") {
                        VStack(spacing: 12) {
                            Toggle("Enable Reminder", isOn: $reminderEnabled)
                                .tint(Color(hex: 0x6C8CFF))
                                .foregroundColor(Color(hex: 0xE8ECF4))

                            if reminderEnabled {
                                DatePicker(
                                    "Reminder Time",
                                    selection: $reminderTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .datePickerStyle(.compact)
                                .tint(Color(hex: 0x6C8CFF))
                                .foregroundColor(Color(hex: 0xE8ECF4))
                            }
                        }
                        .padding(12)
                        .background(Color(hex: 0x242836))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color(hex: 0x0F1117).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(habit == nil ? "New Habit" : "Edit Habit")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: 0x8B95A8))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHabit()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(name.isEmpty ? Color(hex: 0x8B95A8) : Color(hex: 0x6C8CFF))
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    // MARK: - Helpers

    private func fieldSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: 0x8B95A8))
                .tracking(0.5)
            content()
        }
    }

    private func saveHabit() {
        let reminderTimeString = reminderEnabled ? timeFormatter.string(from: reminderTime) : nil
        let days: [String]? = frequency == .custom ? Array(customDays) : nil

        onSave(name, description, category, frequency, days, targetValue, targetUnit, reminderTimeString, reminderEnabled)
        dismiss()
    }
}

// MARK: - Custom Text Field Style

struct EMOpsTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color(hex: 0x242836))
            .cornerRadius(10)
            .foregroundColor(Color(hex: 0xE8ECF4))
    }
}

#Preview {
    HabitEditView(habit: nil) { _, _, _, _, _, _, _, _, _ in }
}
