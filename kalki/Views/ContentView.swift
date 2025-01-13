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
                NavigationStack {
                    TabView(selection: $selectedTab) {
                        FoodLogView(viewModel: foodLogViewModel)
                            .toolbar {
                                ToolbarItem(placement: .principal) {
                                    LogoView()
                                        .opacity(foodLogViewModel.shouldShowLogo ? 1 : 0)
                                }
                            }
                            .toolbarBackground(.hidden, for: .navigationBar)
                            .tabItem {
                                Label("Food Log", systemImage: "list.bullet")
                            }
                            .tag(0)
                    
                        
                        SettingsView()
                            .toolbar {
                                ToolbarItem(placement: .principal) {
                                    Color.clear.frame(height: 8)
                                }
                            }
                            .toolbarBackground(.visible, for: .navigationBar)
                            .tabItem {
                                Label("Settings", systemImage: "gear")
                            }
                            .tag(3)
                    }
                    .tint(AppTheme.accentColor)
                }
            }
        }
    }
} 