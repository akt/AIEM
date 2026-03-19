import SwiftUI

struct OnboardingConfig {
    var timezone: String = "Indian/Maldives"
    var selectedSurfaces: Set<String> = ["Web3/DEX", "Exchange"]
    var dsaaTriggerTime: String = "09:00"
    var notifyDailyDsaa: Bool = true
    var notifyWeeklyFill: Bool = true
    var notifyDeepWork: Bool = true
    var notifyScorecard: Bool = true
}

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var config = OnboardingConfig()
    let onComplete: (OnboardingConfig) -> Void

    private let totalSteps = 4
    private let allSurfaces = ["Web3/DEX", "Exchange", "Fiat On/Off Ramp", "Crypto Pay", "AI Platform/Agents"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress
                ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                Text("Step \(currentStep + 1) of \(totalSteps)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                // Content
                TabView(selection: $currentStep) {
                    welcomeStep.tag(0)
                    timezoneStep.tag(1)
                    surfacesStep.tag(2)
                    notificationsStep.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)

                // Navigation
                HStack {
                    if currentStep > 0 {
                        Button("Back") { currentStep -= 1 }
                            .buttonStyle(.bordered)
                    }
                    Spacer()
                    Button(currentStep == totalSteps - 1 ? "Get Started" : "Next") {
                        if currentStep < totalSteps - 1 {
                            currentStep += 1
                        } else {
                            onComplete(config)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle("Setup EMOps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if currentStep > 0 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Skip") { onComplete(config) }
                    }
                }
            }
        }
    }

    // MARK: - Steps

    private var welcomeStep: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bolt.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(.blue)
            Text("Welcome to EMOps")
                .font(.title.bold())
            Text("Your Engineering Manager Weekly Operating System.\nLet's set up your workspace.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var timezoneStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Select Your Timezone")
                    .font(.title2.bold())
                Text("This determines when your reminders and DSAA ritual fire.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                let timezones: [(String, String)] = [
                    ("Indian/Maldives", "Maldives (UTC+5)"),
                    ("Asia/Kolkata", "India (UTC+5:30)"),
                    ("America/New_York", "US Eastern (UTC-5)"),
                    ("America/Los_Angeles", "US Pacific (UTC-8)"),
                    ("Europe/London", "UK (UTC+0)"),
                    ("Asia/Singapore", "Singapore (UTC+8)"),
                    ("Asia/Dubai", "Dubai (UTC+4)")
                ]

                ForEach(timezones, id: \.0) { tz, label in
                    Button {
                        config.timezone = tz
                    } label: {
                        HStack {
                            Image(systemName: config.timezone == tz ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(config.timezone == tz ? .blue : .secondary)
                            Text(label)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding()
                        .background(config.timezone == tz ? Color.blue.opacity(0.1) : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
    }

    private var surfacesStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Your Product Surfaces")
                    .font(.title2.bold())
                Text("Select the surfaces you own or contribute to.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ForEach(allSurfaces, id: \.self) { surface in
                    let isSelected = config.selectedSurfaces.contains(surface)
                    Button {
                        if isSelected {
                            config.selectedSurfaces.remove(surface)
                        } else {
                            config.selectedSurfaces.insert(surface)
                        }
                    } label: {
                        HStack {
                            Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                .foregroundStyle(isSelected ? .blue : .secondary)
                            Text(surface)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding()
                        .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
    }

    private var notificationsStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Notifications & DSAA")
                    .font(.title2.bold())
                Text("Configure your daily DSAA ritual time and notification preferences.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                GroupBox("DSAA Trigger Time") {
                    TextField("Time (HH:MM)", text: $config.dsaaTriggerTime)
                        .textFieldStyle(.roundedBorder)
                }

                GroupBox("Notifications") {
                    VStack(spacing: 4) {
                        Toggle("Daily DSAA Reminder", isOn: $config.notifyDailyDsaa)
                        Toggle("Weekly Sheet Fill Reminder", isOn: $config.notifyWeeklyFill)
                        Toggle("Deep Work Start Alert", isOn: $config.notifyDeepWork)
                        Toggle("Friday Scorecard Reminder", isOn: $config.notifyScorecard)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
    }
}
