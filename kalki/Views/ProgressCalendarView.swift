import SwiftUI

/// ProgressCalendarView provides a user interface for tracking progress over time.
struct ProgressCalendarView: View {
    @StateObject private var viewModel: ProgressViewModel
    @State private var month: Date
    @State private var showingAchievements = false
    
    init(exerciseService: ExerciseService, foodLogViewModel: FoodLogViewModel) {
        let today = Calendar.current.startOfDay(for: Date())
        _month = State(initialValue: today)
        _viewModel = StateObject(wrappedValue: ProgressViewModel(exerciseService: exerciseService, foodLogViewModel: foodLogViewModel))
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private var monthStats: (successful: Int, total: Int, longestStreak: Int) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        var date = monthStart
        var successful = 0
        var total = 0
        var currentStreak = 0
        var longestStreak = 0
        
        while date <= today && calendar.isDate(date, equalTo: month, toGranularity: .month) {
            if let progress = viewModel.getProgress(for: date) {
                // TODO: Replace with user-specific calorie goals based on:
                // - Basal Metabolic Rate (BMR) using height, weight, age
                // - Activity level multiplier
                // - Weight goal (maintain/lose/gain)
                let calorieGoal = Double(viewModel.dailyCalorieGoal) ?? 2000
                
                let calorieRatio = progress.calories / calorieGoal
                let isGoalMet = calorieRatio <= 1.0 // Day is achieved if calories are under limit
                
                if isGoalMet {
                    successful += 1
                    currentStreak += 1
                    longestStreak = max(longestStreak, currentStreak)
                } else {
                    currentStreak = 0
                }
                total += 1
            }
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return (successful, total, longestStreak)
    }
    
    private var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: Date())
        
        while let progress = viewModel.getProgress(for: currentDate) {
            // TODO: Replace with user-specific calorie goals based on:
            // - Basal Metabolic Rate (BMR) using height, weight, age
            // - Activity level multiplier
            // - Weight goal (maintain/lose/gain)
            let calorieGoal = Double(viewModel.dailyCalorieGoal) ?? 2000
            
            let calorieRatio = progress.calories / calorieGoal
            let isGoalMet = calorieRatio <= 1.0 // Day is achieved if calories are under limit
            
            if !isGoalMet {
                break
            }
            
            streak += 1
            guard let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previousDate
        }
        
        return streak
    }
    
    private func isPartOfStreak(_ date: Date) -> Bool {
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: Date())
        var streakDates: Set<Date> = []
        
        while let progress = viewModel.getProgress(for: currentDate) {
            // TODO: Replace with user-specific calorie goals based on:
            // - Basal Metabolic Rate (BMR) using height, weight, age
            // - Activity level multiplier
            // - Weight goal (maintain/lose/gain)
            let calorieGoal = Double(viewModel.dailyCalorieGoal) ?? 2000
            
            let calorieRatio = progress.calories / calorieGoal
            let isGoalMet = calorieRatio <= 1.0 // Day is achieved if calories are under limit
            
            if !isGoalMet {
                break
            }
            
            streakDates.insert(currentDate)
            guard let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previousDate
        }
        
        return streakDates.contains(calendar.startOfDay(for: date))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Calendar grid
                VStack(spacing: 8) {
                    // Month navigation
                    HStack {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                month = Calendar.current.date(byAdding: .month, value: -1, to: month) ?? month
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .imageScale(.large)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(monthFormatter.string(from: month))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.text.primary)
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: month) ?? month
                                if newMonth <= Date() {
                                    month = newMonth
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .imageScale(.large)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                        .disabled(Calendar.current.isDate(month, equalTo: Date(), toGranularity: .month))
                    }
                    .padding(.horizontal)
                    .overlay(alignment: .trailing) {
                        Button {
                            showingAchievements = true
                        } label: {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(AppTheme.highlightColor)
                                .padding(8)
                                .background {
                                    Circle()
                                        .fill(.background)
                                        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                                }
                        }
                        .offset(x: 44)
                    }
                    
                    ProgressCalendarGrid(
                        month: month,
                        progressMap: viewModel.dailyProgressMap,
                        calorieGoal: Double(viewModel.dailyCalorieGoal) ?? 2000,
                        proteinGoal: Double(viewModel.dailyProteinGoal) ?? 150,
                        selectedDate: $viewModel.selectedDate,
                        isPartOfStreak: isPartOfStreak
                    )
                    .padding(.horizontal)
                }
                
                // Legend
                HStack(spacing: 16) {
                    LegendItem(color: AppTheme.successColor, label: "Goals Met")
                    LegendItem(color: AppTheme.states.attention, label: "Over Limit")
                    LegendItem(color: AppTheme.accentColor.opacity(0.5), label: "Some Progress")
                }
                .font(.caption)
                .padding(.top, 4)
                
                Divider()
                    .padding(.vertical, 8)
                
                // Quick Stats
                let stats = monthStats
                if stats.total > 0 {
                    HStack(spacing: 16) {
                        // Success rate
                        VStack(spacing: 2) {
                            Text("\(stats.successful)/\(stats.total)")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.successColor)
                            Text("Goals Met")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Divider()
                            .frame(height: 24)
                        
                        // Longest streak
                        VStack(spacing: 2) {
                            Text("\(stats.longestStreak)")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.successColor)
                            Text("Best Streak")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Streak indicator
                if currentStreak > 0 {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(AppTheme.successColor)
                        Text("\(currentStreak) Day Streak!")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.successColor)
                    }
                    .padding(.vertical, 4)
                }
                
                // Day Summary (if data exists and not future date)
                if let progress = viewModel.getProgress(for: viewModel.selectedDate),
                   viewModel.selectedDate <= Date() {
                    VStack(spacing: 12) {
                        Text(viewModel.selectedDate.formatted(date: .complete, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 20) {
                            // Calories
                            DayStat(
                                value: Int(progress.calories),
                                goal: Int(Double(viewModel.dailyCalorieGoal) ?? 2000),
                                unit: "kcal",
                                icon: "flame.fill",
                                color: AppTheme.ringColors.primary
                            )
                            
                            // Protein
                            DayStat(
                                value: Int(progress.proteins),
                                goal: Int(Double(viewModel.dailyProteinGoal) ?? 150),
                                unit: "g",
                                icon: "figure.strengthtraining.traditional",
                                color: AppTheme.ringColors.secondary
                            )
                            
                            // Exercise
                            DayStat(
                                value: Int(progress.exerciseProgress.activeCalories),
                                goal: Int(progress.exerciseProgress.activeCalorieGoal),
                                unit: "kcal",
                                icon: "heart.fill",
                                color: AppTheme.ringColors.tertiary
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Spacer()
            }
            .padding(.vertical)
            .refreshable {
                await viewModel.refreshProgress()
            }
            .sheet(isPresented: $showingAchievements) {
                AchievementsView()
            }
        }
        .onAppear {
            // Set initial date to today
            let today = Calendar.current.startOfDay(for: Date())
            viewModel.selectedDate = today
        }
        .onChange(of: month) { _, newMonth in
            Task {
                await viewModel.loadProgress()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .foodAdded)) { _ in
            Task {
                await viewModel.loadProgress()
            }
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ProgressCalendarView(
        exerciseService: MockExerciseService(),
        foodLogViewModel: FoodLogViewModel(nutritionService: MockNutritionService())
    )
} 