import SwiftUI

struct HabitsView: View {
    @StateObject var viewModel = HabitsViewModel()
    @State private var showingAddHabit = false

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f
    }()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection

                    // Progress bar
                    progressSection

                    // Grouped habits by category
                    ForEach(HabitCategory.allCases, id: \.self) { category in
                        if let habits = viewModel.groupedHabits[category], !habits.isEmpty {
                            categorySection(category: category, habits: habits)
                        }
                    }

                    // Add Custom Habit button
                    Button {
                        showingAddHabit = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Custom Habit")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0x6C8CFF))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: 0x6C8CFF).opacity(0.12))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color(hex: 0x0F1117).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Habits")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                }
            }
            .overlay {
                if viewModel.isLoading && viewModel.habits.isEmpty {
                    ProgressView()
                        .tint(Color(hex: 0x6C8CFF))
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                HabitEditView(habit: nil) { name, description, category, frequency, customDays, targetValue, targetUnit, reminderTime, reminderEnabled in
                    Task {
                        await viewModel.createHabit(
                            name: name,
                            description: description,
                            category: category,
                            frequency: frequency,
                            targetValue: targetValue,
                            targetUnit: targetUnit,
                            reminderTime: reminderTime,
                            reminderEnabled: reminderEnabled
                        )
                    }
                }
            }
        }
        .task {
            await viewModel.loadHabits()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Today's Habits")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: 0xE8ECF4))
            Text(dateFormatter.string(from: viewModel.selectedDate))
                .font(.subheadline)
                .foregroundColor(Color(hex: 0x8B95A8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    // MARK: - Progress

    private var progressSection: some View {
        EMOpsCard {
            VStack(spacing: 12) {
                HStack {
                    Text("\(viewModel.completedCount)/\(viewModel.totalCount) completed")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: 0xE8ECF4))
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(Color(hex: 0xFFB84D))
                            .font(.caption)
                        Text("\(viewModel.currentStreak) day streak")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: 0xFFB84D))
                    }
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: 0x242836))
                            .frame(height: 10)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: 0x00D4AA))
                            .frame(
                                width: viewModel.totalCount > 0
                                    ? geometry.size.width * CGFloat(viewModel.completedCount) / CGFloat(viewModel.totalCount)
                                    : 0,
                                height: 10
                            )
                    }
                }
                .frame(height: 10)
            }
        }
    }

    // MARK: - Category Section

    private func categorySection(category: HabitCategory, habits: [Habit]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(categoryDisplayName(category))
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: 0x8B95A8))
                .tracking(1)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(habits) { habit in
                    NavigationLink(destination: HabitDetailView(habit: habit)) {
                        HabitRow(
                            habit: habit,
                            isCompleted: viewModel.habitLogs[habit.id]?.isCompleted ?? false,
                            onToggle: {
                                Task {
                                    await viewModel.toggleHabit(habit)
                                }
                            }
                        )
                    }
                    .buttonStyle(.plain)

                    if habit.id != habits.last?.id {
                        Divider()
                            .background(Color(hex: 0x242836))
                            .padding(.leading, 52)
                    }
                }
            }
            .background(Color(hex: 0x1A1D27))
            .cornerRadius(12)
        }
    }

    // MARK: - Helpers

    private func categoryDisplayName(_ category: HabitCategory) -> String {
        switch category {
        case .deepWork: return "DEEP WORK & PRODUCTIVITY"
        case .reliability: return "RELIABILITY & SRE"
        case .delivery: return "DELIVERY & EXECUTION"
        case .security: return "SECURITY & COMPLIANCE"
        case .aiSafety: return "AI SAFETY & ETHICS"
        case .leadership: return "LEADERSHIP & GROWTH"
        case .health: return "HEALTH & WELLBEING"
        case .learning: return "LEARNING & DEVELOPMENT"
        }
    }
}

#Preview {
    HabitsView()
}
