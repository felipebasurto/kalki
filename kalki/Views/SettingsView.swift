import SwiftUI

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showingOnboarding = false
    @State private var apiKey = AppConfig.openAIKey
    @State private var showingAPIKeyInfo = false
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationStack {
            LogoView()
            Form {
                Section("Profile & Goals") {
                    NavigationLink("Calculate Needs") {
                        CalcView()
                    }
                }
                
                Section("Appearance") {
                    Picker("Theme", selection: Binding(
                        get: { themeManager.currentThemePreference },
                        set: { themeManager.setThemePreference($0) }
                    )) {
                        Text("Light").tag(ThemeManager.ThemePreference.light)
                        Text("Dark").tag(ThemeManager.ThemePreference.dark)
                        Text("System").tag(ThemeManager.ThemePreference.system)
                    }
                }
                
                Section("AI Configuration") {
                    SecureField("OpenAI API Key", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(of: apiKey) { _, newValue in
                            AppConfig.openAIKey = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    
                    Button("About API Key") {
                        showingAPIKeyInfo = true
                    }
                }
                
                Section("App Settings") {
                    Button("Reset Onboarding") {
                        hasCompletedOnboarding = false
                        showingOnboarding = true
                    }
                }
            }
            .navigationTitle("Settings")
            .fullScreenCover(isPresented: $showingOnboarding) {
                OnboardingView()
            }
            .alert("About OpenAI API Key", isPresented: $showingAPIKeyInfo) {
                Button("Get API Key") {
                    if let url = URL(string: "https://platform.openai.com/api-keys") {
                        UIApplication.shared.open(url)
                    }
                }
                Button("OK", role: .cancel) { }
            } message: {
                Text("An OpenAI API key is required for accurate food analysis. You can get one from your OpenAI account. The key is stored securely on your device.")
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
} 
