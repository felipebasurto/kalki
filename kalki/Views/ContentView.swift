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
        
        // Set navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
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
                            .tabItem {
                                Label("Food Log", systemImage: "list.bullet")
                            }
                            .tag(0)
                        
                        ProgressCalendarView(
                            exerciseService: exerciseService,
                            foodLogViewModel: foodLogViewModel
                        )
                        .tabItem {
                            Label("Progress", systemImage: "chart.bar.fill")
                        }
                        .tag(1)
                        
                        CalcView()
                            .tabItem {
                                Label("Calculate", systemImage: "function")
                            }
                            .tag(2)
                        
                        SettingsView()
                            .tabItem {
                                Label("Settings", systemImage: "gear")
                            }
                            .tag(3)
                    }
                    .tint(AppTheme.accentColor)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            LogoView()
                        }
                    }
                    .toolbarBackground(.visible, for: .navigationBar)
                }
            }
        }
    }
} 