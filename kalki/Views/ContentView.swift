import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 0
    @StateObject private var foodLogViewModel: FoodLogViewModel
    @StateObject private var exerciseService = MockExerciseService()
    
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
                                    LogoView()
                                        .opacity(foodLogViewModel.shouldShowLogo ? 1 : 0)
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
                    }
                    .tabItem {
                        Label("Progress", systemImage: "calendar")
                    }
                    .tag(1)
                    
                    NavigationStack {
                        SettingsView()
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