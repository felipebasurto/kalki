import SwiftUI
import CoreData

/// ProgressCalendarView provides a user interface for tracking progress over time.
struct ProgressCalendarView: View {
    // MARK: - Properties
    @StateObject private var viewModel: ProgressViewModel
    @State private var month: Date
    @State private var showingAchievements = false
    @State private var scrollOffset: CGFloat = 0
    
    // MARK: - Initialization
    init(exerciseService: ExerciseService, foodLogViewModel: FoodLogViewModel) {
        let today = Calendar.current.startOfDay(for: Date())
        _month = State(initialValue: today)
        _viewModel = StateObject(wrappedValue: ProgressViewModel(exerciseService: exerciseService, foodLogViewModel: foodLogViewModel))
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                scrollOffsetDetector
                calendarHeader
                calendarGrid
                legendView
                if let progress = viewModel.getProgress(for: viewModel.selectedDate),
                   viewModel.selectedDate <= Date() {
                    dailyProgressView(progress: progress)
                }
                if currentStreak > 0 || monthStats.total > 0 {
                    statsCard
                }
                Spacer()
            }
            .padding(.vertical)
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
        .refreshable {
            await viewModel.refreshProgress()
        }
        .sheet(isPresented: $showingAchievements) {
            AchievementsView()
        }
        .onAppear {
            viewModel.selectedDate = Calendar.current.startOfDay(for: Date())
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
    
    // MARK: - View Components
    private var scrollOffsetDetector: some View {
        GeometryReader { proxy in
            Color.clear.preference(
                key: ScrollOffsetPreferenceKey.self,
                value: proxy.frame(in: .named("scroll")).minY
            )
        }
        .frame(height: 0)
    }
    
    private var calendarHeader: some View {
        VStack {
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        month = Calendar.current.date(byAdding: .month, value: -1, to: month)!
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundStyle(AppTheme.text.primary)
                }
                
                Spacer()
                
                Text(month.formatted(.dateTime.month().year()))
                    .font(.title3.bold())
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        month = Calendar.current.date(byAdding: .month, value: 1, to: month)!
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundStyle(AppTheme.text.primary)
                }
                .disabled(Calendar.current.isDate(month, equalTo: Date(), toGranularity: .month))
            }
            .padding(.horizontal)
            .overlay(alignment: .trailing) {
                achievementsButton
            }
        }
        .padding(.top)
        .opacity(min(1, 1 + scrollOffset / 50))
    }
    
    private var achievementsButton: some View {
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
    
    private var calendarGrid: some View {
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
    
    private var legendView: some View {
        HStack(spacing: 16) {
            LegendItem(color: AppTheme.successColor, label: "Goals Met")
            LegendItem(color: AppTheme.states.attention, label: "Over Limit")
            LegendItem(color: AppTheme.accentColor.opacity(0.5), label: "Some Progress")
        }
        .font(.caption)
        .padding(.top, 4)
    }
    
    private func dailyProgressView(progress: DailyProgress) -> some View {
        VStack(spacing: 12) {
            Text(viewModel.selectedDate.formatted(date: .complete, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 20) {
                DayStat(
                    value: Int(progress.calories),
                    goal: Int(Double(viewModel.dailyCalorieGoal) ?? 2000),
                    unit: "kcal",
                    icon: "flame.fill",
                    color: AppTheme.ringColors.primary
                )
                
                DayStat(
                    value: Int(progress.proteins),
                    goal: Int(Double(viewModel.dailyProteinGoal) ?? 150),
                    unit: "g",
                    icon: "figure.strengthtraining.traditional",
                    color: AppTheme.ringColors.secondary
                )
                
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
    
    private var statsCard: some View {
        VStack(spacing: 16) {
            if monthStats.total > 0 {
                HStack(spacing: 16) {
                    VStack(spacing: 2) {
                        Text("\(monthStats.successful)/\(monthStats.total)")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.successColor)
                        Text("Goals Met")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                        .frame(height: 24)
                    
                    VStack(spacing: 2) {
                        Text("\(monthStats.longestStreak)")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.successColor)
                        Text("Best Streak")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            if currentStreak > 0 {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(AppTheme.successColor)
                    Text("\(currentStreak) Day Streak!")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.successColor)
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: Color(.systemGray4).opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Methods
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
                let calorieGoal = Double(viewModel.dailyCalorieGoal) ?? 2000
                let calorieRatio = progress.calories / calorieGoal
                let isGoalMet = calorieRatio <= 1.0
                
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
            let calorieGoal = Double(viewModel.dailyCalorieGoal) ?? 2000
            let calorieRatio = progress.calories / calorieGoal
            let isGoalMet = calorieRatio <= 1.0
            
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
            let calorieGoal = Double(viewModel.dailyCalorieGoal) ?? 2000
            let calorieRatio = progress.calories / calorieGoal
            let isGoalMet = calorieRatio <= 1.0
            
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
}

// MARK: - Supporting Views
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
    ProgressCalendarView(exerciseService: MockExerciseService(), foodLogViewModel: FoodLogViewModel())
} 