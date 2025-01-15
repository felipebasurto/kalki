import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 0
    @StateObject private var foodLogViewModel: FoodLogViewModel
    @StateObject private var exerciseService = MockExerciseService()
    @State private var logoOpacity: Double = 1.0
    
    init() {
        let nutritionService: NutritionService = AppConfig.hasValidOpenAIKey 
            ? OpenAINutritionService(apiKey: AppConfig.openAIKey)
            : MockNutritionService()
            
        _foodLogViewModel = StateObject(wrappedValue: FoodLogViewModel(nutritionService: nutritionService))
        
        // Set tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().tintColor = UIColor(AppTheme.accentColor)
        
        // Optimize initial view loading
        if #available(iOS 15.0, *) {
            do {
                UIView.setAnimationsEnabled(false)
                do { UIView.setAnimationsEnabled(true) }
                // Any additional setup code can go here
            }
        }
    }
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else {
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        FoodLogView(viewModel: foodLogViewModel)
                            .toolbar {
                                ToolbarItem(placement: .principal) {
                                    LogoView(opacity: logoOpacity)
                                }
                            }
                    }
                    .tabItem {
                        Label("Food Log", systemImage: "list.bullet")
                    }
                    .tag(0)
                    
                    NavigationStack {
                        ProgressCalendarView(exerciseService: exerciseService, foodLogViewModel: foodLogViewModel)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .principal) {
                                    LogoView(opacity: logoOpacity)
                                }
                            }
                    }
                    .tabItem {
                        Label("Progress", systemImage: "calendar")
                    }
                    .tag(1)
                    
                    NavigationStack {
                        SettingsView()
                            .toolbar {
                                ToolbarItem(placement: .principal) {
                                    LogoView(opacity: logoOpacity)
                                }
                            }
                    }
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(2)
                }
                .tint(AppTheme.accentColor)
            }
        }
    }
}

#Preview {
    ContentView()
} 
