import SwiftUI

// MARK: - CalorieCircle
/// Displays a circular progress indicator for calories eaten and optional breakdown per meal.
/// - Parameters:
///   - caloriesEaten (Int): Total calories consumed.
///   - caloriesBurned (Int): Total calories burned.
///   - calorieGoal (Int): Daily calorie goal.
///   - mealBreakdown (Array): List of meals with their calorie amounts.
struct CalorieCircle: View {
    let caloriesEaten: Int
    let caloriesBurned: Int
    let calorieGoal: Int
    let mealBreakdown: [(mealType: MealType, calories: Int)]
    
    @State private var showingMealBreakdown = false
    @State private var selectedMeal: MealType?
    @State private var animationProgress: Double = 0
    @Environment(\.colorScheme) private var colorScheme
    
    private let ringWidth: Double = 20
    
    var body: some View {
        VStack(spacing: 16) {
            mainCircle
            
            if showingMealBreakdown {
                MealLegend(
                    activeMeals: activeMeals,
                    selectedMeal: $selectedMeal,
                    mealColor: mealColor
                )
            }
        }
        .onChange(of: showingMealBreakdown) { _, newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                if newValue {
                    animationProgress = 1
                } else {
                    animationProgress = 0
                }
            }
        }
    }
}

// MARK: - Main Components
private extension CalorieCircle {
    var mainCircle: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color(.systemGray6), lineWidth: ringWidth)
            
            // Segments if meal breakdown is visible, otherwise a single progress ring
            if showingMealBreakdown && !mealBreakdown.isEmpty {
                MealSegments(
                    activeMeals: activeMeals,
                    ringWidth: ringWidth,
                    mealColor: mealColor,
                    animationProgress: animationProgress
                )
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            } else {
                CalorieProgressRing(
                    progress: totalProgress * (1 - animationProgress),
                    ringWidth: ringWidth
                )
            }
            
            // Center text content
            CenterContent(
                showingMealBreakdown: showingMealBreakdown,
                selectedMeal: selectedMeal,
                mealBreakdown: mealBreakdown,
                caloriesEaten: caloriesEaten,
                calorieGoal: calorieGoal,
                caloriesBurned: caloriesBurned,
                mealColor: mealColor
            )
        }
        .frame(height: 200)
        .padding()
        .contentShape(Rectangle())
        .onTapGesture(perform: handleTap)
    }
}

// MARK: - Helper Methods
private extension CalorieCircle {
    /// The ratio of calories eaten to the calorie goal.
    var totalProgress: Double {
        Double(caloriesEaten) / Double(calorieGoal)
    }
    
    /// Filters out any meals with zero calories.
    var activeMeals: [(mealType: MealType, calories: Int)] {
        mealBreakdown.filter { $0.calories > 0 }
    }
    
    /// Returns the appropriate color for a meal type:
    /// - If showing meal breakdown with a selected meal, only the selected meal will show its color while others are dimmed.
    /// - If no meal is selected, each meal is shown with its default color.
    /// - Outside of meal breakdown, the accent color is returned.
    func mealColor(_ mealType: MealType) -> Color {
        if showingMealBreakdown {
            if let selectedMeal = selectedMeal {
                return selectedMeal == mealType ? mealType.color : Color(.systemGray4)
            }
            return mealType.color
        }
        return AppTheme.accentColor
    }
    
    /// Toggles meal breakdown display, and clears a selected meal when needed.
    func handleTap() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if selectedMeal != nil {
                selectedMeal = nil
            } else {
                showingMealBreakdown.toggle()
            }
        }
    }
}

// MARK: - CalorieProgressRing
/// A single-ring progress indicator showing overall calorie consumption progress.
private struct CalorieProgressRing: View {
    let progress: Double
    let ringWidth: Double
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Circle()
            .trim(from: 0, to: min(progress, 1))
            .stroke(
                AppTheme.accentColor,
                style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 0.5), value: progress)
    }
}

// MARK: - MealSegments
/// Renders individual colored ring segments for each active meal.
private struct MealSegments: View {
    let activeMeals: [(mealType: MealType, calories: Int)]
    let ringWidth: Double
    let mealColor: (MealType) -> Color
    let animationProgress: Double
    
    var body: some View {
        ForEach(activeMeals, id: \.mealType) { meal in
            MealSegment(
                meal: meal,
                totalCalories: totalCalories,
                activeMeals: activeMeals,
                ringWidth: ringWidth,
                mealColor: mealColor,
                animationProgress: animationProgress
            )
        }
    }
    
    private var totalCalories: Double {
        Double(activeMeals.reduce(0) { $0 + $1.calories })
    }
}

// MARK: - MealSegment
/// A single ring segment for a particular meal.
private struct MealSegment: View {
    let meal: (mealType: MealType, calories: Int)
    let totalCalories: Double
    let activeMeals: [(mealType: MealType, calories: Int)]
    let ringWidth: Double
    let mealColor: (MealType) -> Color
    let animationProgress: Double
    
    var body: some View {
        Circle()
            .trim(from: startAngle * animationProgress, to: endAngle * animationProgress)
            .stroke(
                animatedColor,
                style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
    }
    
    private var animatedColor: Color {
        if animationProgress < 0.5 {
            return Color(.systemGray4)
        } else {
            return mealColor(meal.mealType)
        }
    }
    
    private var startAngle: Double {
        guard let index = activeMeals.firstIndex(where: { $0.mealType == meal.mealType }) else { return 0 }
        let previousCalories = activeMeals[..<index].reduce(0) { $0 + Double($1.calories) }
        return previousCalories / totalCalories
    }
    
    private var endAngle: Double {
        guard let index = activeMeals.firstIndex(where: { $0.mealType == meal.mealType }) else { return 0 }
        let previousCalories = activeMeals[..<(index + 1)].reduce(0) { $0 + Double($1.calories) }
        return previousCalories / totalCalories
    }
}

// MARK: - CenterContent
/// Displays either meal-specific info or total calorie info in the center of the ring(s).
private struct CenterContent: View {
    let showingMealBreakdown: Bool
    let selectedMeal: MealType?
    let mealBreakdown: [(mealType: MealType, calories: Int)]
    let caloriesEaten: Int
    let calorieGoal: Int
    let caloriesBurned: Int
    let mealColor: (MealType) -> Color
    
    var body: some View {
        VStack(spacing: 4) {
            if showingMealBreakdown {
                mealBreakdownContent
            } else {
                totalCaloriesContent
            }
        }
    }
    
    private var mealBreakdownContent: some View {
        Group {
            if let selectedMeal,
               let mealData = mealBreakdown.first(where: { $0.mealType == selectedMeal }) {
                selectedMealContent(mealData)
            } else {
                Text("Meal Split")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func selectedMealContent(_ mealData: (mealType: MealType, calories: Int)) -> some View {
        VStack(spacing: 4) {
            Text(mealData.mealType.rawValue)
                .font(.headline)
                .foregroundStyle(mealColor(mealData.mealType))
            
            AnimatedNumber(
                value: Double(mealData.calories),
                font: .system(size: 36, weight: .bold)
            )
            .foregroundStyle(mealColor(mealData.mealType))
            
            Text("kcal")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("\(Int((Double(mealData.calories) / Double(caloriesEaten) * 100).rounded()))%")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
    }
    
    private var totalCaloriesContent: some View {
        VStack(spacing: 4) {
            AnimatedNumber(
                value: Double(caloriesEaten),
                font: .system(size: 36, weight: .bold),
                color: AppTheme.accentColor
            )
            
            Text("/ \(calorieGoal) kcal")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("🔥 \(caloriesBurned) burned")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
    }
}

// MARK: - MealLegend
/// Displays a list of all active meals and lets the user select a specific meal to highlight.
private struct MealLegend: View {
    let activeMeals: [(mealType: MealType, calories: Int)]
    @Binding var selectedMeal: MealType?
    let mealColor: (MealType) -> Color
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(activeMeals.indices, id: \.self) { idx in
                let meal = activeMeals[idx]
                Button {
                    handleMealSelection(meal.mealType)
                } label: {
                    HStack {
                        Circle()
                            .fill(mealColor(meal.mealType))
                            .frame(width: 8, height: 8)
                        
                        Text(meal.mealType.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(selectedMeal == nil || selectedMeal == meal.mealType ? .primary : .secondary)
                        
                        Spacer()
                        
                        AnimatedNumber(
                            value: Double(meal.calories),
                            format: "%.0f kcal",
                            font: .subheadline,
                            color: selectedMeal == nil || selectedMeal == meal.mealType ? .secondary : Color(.tertiaryLabel)
                        )
                    }
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                
                if idx < activeMeals.count - 1 {
                    Divider()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private func handleMealSelection(_ mealType: MealType) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if selectedMeal == mealType {
                selectedMeal = nil
            } else {
                selectedMeal = mealType
            }
        }
    }
}

// MARK: - MealType Color Extension
extension MealType {
    var color: Color {
        switch self {
        case .breakfast:
            return AppTheme.highlightColor
        case .lunch:
            return AppTheme.accentColor
        case .dinner:
            return AppTheme.successColor
        case .snacks:
            return AppTheme.purpleColor
        }
    }
}

// MARK: - Preview
#Preview {
    CalorieCircle(
        caloriesEaten: 1500,
        caloriesBurned: 500,
        calorieGoal: 2000,
        mealBreakdown: [
            (.breakfast, 400),
            (.lunch, 600),
            (.dinner, 400),
            (.snacks, 100)
        ]
    )
}
