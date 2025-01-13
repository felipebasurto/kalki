import Foundation

/// Stores app-wide configuration and settings
enum AppConfig {
    /// The OpenAI API key used for nutrition analysis
    /// - Note: This should be replaced with your actual API key
    static var openAIKey: String {
        get {
            UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "openai_api_key")
        }
    }
    
    /// Whether the app has a valid OpenAI API key
    static var hasValidOpenAIKey: Bool {
        !openAIKey.isEmpty
    }
} 