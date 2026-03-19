import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @State private var selectedTab: Int = 0

    var body: some View {
        Group {
            if authService.isAuthenticated {
                mainView
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authService.isAuthenticated)
    }

    // MARK: - Main Authenticated View

    private var mainView: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Background
                Color(hex: "0F1117").ignoresSafeArea()

                // Tab content
                VStack(spacing: 0) {
                    tabContent
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    TabBar(selectedTab: $selectedTab)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .foregroundColor(Color(hex: "8B95A8"))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case 0:
            DashboardView()
        case 1:
            WeeklySheetView()
        case 2:
            HabitsView()
        case 3:
            TrendsView()
        case 4:
            AiCoachView()
        default:
            DashboardView()
        }
    }
}

// MARK: - Login View

struct LoginView: View {
    @EnvironmentObject var authService: AuthService

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showRegister: Bool = false

    private let backgroundColor = Color(hex: "0F1117")
    private let surfaceColor = Color(hex: "1A1D27")
    private let primaryColor = Color(hex: "6C8CFF")
    private let textColor = Color(hex: "E8ECF4")
    private let textSecondaryColor = Color(hex: "8B95A8")
    private let errorColor = Color(hex: "FF6B6B")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 60)

                    // Logo / Branding
                    VStack(spacing: 8) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 48))
                            .foregroundColor(primaryColor)

                        Text("EMOps")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(textColor)

                        Text("Engineering Manager Operations")
                            .font(.system(size: 14))
                            .foregroundColor(textSecondaryColor)
                    }

                    // Login Form
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(textSecondaryColor)

                            TextField("", text: $email)
                                .textFieldStyle(.plain)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(12)
                                .foregroundColor(textColor)
                                .background(surfaceColor)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(hex: "242836"), lineWidth: 1)
                                )
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(textSecondaryColor)

                            SecureField("", text: $password)
                                .textFieldStyle(.plain)
                                .textContentType(.password)
                                .padding(12)
                                .foregroundColor(textColor)
                                .background(surfaceColor)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(hex: "242836"), lineWidth: 1)
                                )
                        }

                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(errorColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Login Button
                        Button {
                            performLogin()
                        } label: {
                            Group {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Sign In")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .opacity((email.isEmpty || password.isEmpty) ? 0.6 : 1)

                        // Register Link
                        Button {
                            showRegister = true
                        } label: {
                            HStack(spacing: 4) {
                                Text("Don't have an account?")
                                    .foregroundColor(textSecondaryColor)
                                Text("Register")
                                    .foregroundColor(primaryColor)
                                    .fontWeight(.semibold)
                            }
                            .font(.system(size: 14))
                        }
                        .padding(.top, 8)
                    }
                    .padding(24)
                    .background(surfaceColor)
                    .cornerRadius(16)

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }

    private func performLogin() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await authService.login(email: email, password: password)
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Register View

struct RegisterView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss

    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private let backgroundColor = Color(hex: "0F1117")
    private let surfaceColor = Color(hex: "1A1D27")
    private let primaryColor = Color(hex: "6C8CFF")
    private let textColor = Color(hex: "E8ECF4")
    private let textSecondaryColor = Color(hex: "8B95A8")
    private let errorColor = Color(hex: "FF6B6B")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        Text("Create Account")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(textColor)
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(textSecondaryColor)
                        }
                    }
                    .padding(.top, 24)

                    VStack(spacing: 16) {
                        formField(label: "Display Name", text: $displayName)
                        formField(label: "Email", text: $email, keyboard: .emailAddress)
                        secureFormField(label: "Password", text: $password)
                        secureFormField(label: "Confirm Password", text: $confirmPassword)

                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(errorColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button {
                            performRegister()
                        } label: {
                            Group {
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Create Account")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(isLoading || !isFormValid)
                        .opacity(isFormValid ? 1 : 0.6)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private var isFormValid: Bool {
        !displayName.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword
    }

    @ViewBuilder
    private func formField(label: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(textSecondaryColor)
            TextField("", text: text)
                .textFieldStyle(.plain)
                .keyboardType(keyboard)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(12)
                .foregroundColor(textColor)
                .background(surfaceColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "242836"), lineWidth: 1)
                )
        }
    }

    @ViewBuilder
    private func secureFormField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(textSecondaryColor)
            SecureField("", text: text)
                .textFieldStyle(.plain)
                .padding(12)
                .foregroundColor(textColor)
                .background(surfaceColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "242836"), lineWidth: 1)
                )
        }
    }

    private func performRegister() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await authService.register(email: email, password: password, displayName: displayName)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AuthService.shared)
        .environmentObject(SyncService.shared)
}
