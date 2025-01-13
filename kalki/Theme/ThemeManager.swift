import SwiftUI

@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("userThemePreference") private var userThemePreference: ThemePreference = .system
    @Published private(set) var isDarkMode: Bool = false
    
    enum ThemePreference: String {
        case light, dark, system
    }
    
    private init() {
        updateThemeBasedOnPreference()
    }
    
    var currentThemePreference: ThemePreference {
        userThemePreference
    }
    
    func setThemePreference(_ preference: ThemePreference) {
        userThemePreference = preference
        updateThemeBasedOnPreference()
    }
    
    func updateThemeBasedOnPreference() {
        switch userThemePreference {
        case .light:
            isDarkMode = false
        case .dark:
            isDarkMode = true
        case .system:
            isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        }
    }
} 