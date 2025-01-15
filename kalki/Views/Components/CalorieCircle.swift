import SwiftUI

struct CalorieCircle: View {
    let caloriesEaten: Int
    let caloriesBurned: Int
    let calorieGoal: Int
    let mealBreakdown: [(mealType: MealType, calories: Int)]
    
    @State private var showingMealBreakdown = false
    @State private var selectedMeal: MealType?
    @Environment(\.colorScheme) private var colorScheme
    
    private let ringWidth: Double = 20
    private let segmentSpacing: Double = 4 // Spacing between segments in degrees
    
    private var totalProgress: Double {
        Double(caloriesEaten) / Double(calorieGoal)
    }
    
    private var mealSegments: [(startAngle: Double, endAngle: Double, color: Color)] {
        var segments: [(startAngle: Double, endAngle: Double, color: Color)] = []
        var currentAngle: Double = 0
        let totalCalories = Double(caloriesEaten)
        let activeMeals = mealBreakdown.filter { $0.calories > 0 }
        let totalSpacing = segmentSpacing * Double(activeMeals.count - 1)
        let availableAngle = 360.0 - totalSpacing
        
        for meal in activeMeals {
            let proportion = Double(meal.calories) / totalCalories
            let segmentAngle = availableAngle * proportion
            
            segments.append((
                startAngle: currentAngle,
                endAngle: currentAngle + segmentAngle,
                color: meal.mealType.color
            ))
            
            currentAngle += segmentAngle + segmentSpacing
        }
        
        return segments
    }
    
    private func mealColor(_ mealType: MealType) -> Color {
        if showingMealBreakdown {
            if let selectedMeal = selectedMeal {
                return selectedMeal == mealType ? (mealType.color) : Color(.systemGray4)
            }
            return mealType.color
        }
        return AppTheme.accentColor
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(
                        Color(.systemGray6),
                        lineWidth: ringWidth
                    )
                
                if showingMealBreakdown && !mealBreakdown.isEmpty {
                    // Meal breakdown circles
                    ForEach(mealBreakdown.filter { $0.calories > 0 }, id: \.mealType) { meal in
                        let startAngle = startAngle(for: meal)
                        let endAngle = endAngle(for: meal)
                        
                        Circle()
                            .trim(from: startAngle, to: endAngle)
                            .stroke(
                                mealColor(meal.mealType),
                                style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                    }
                    .transition(.opacity)
                } else {
                    // Total calories circle
                    Circle()
                        .trim(from: 0, to: min(totalProgress, 1))
                        .stroke(
                            AppTheme.accentColor,
                            style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }
                
                // Center content
                VStack(spacing: 4) {
                    if showingMealBreakdown {
                        if let selectedMeal = selectedMeal,
                           let mealData = mealBreakdown.first(where: { $0.mealType == selectedMeal }) {
                            Text(mealData.mealType.rawValue)
                                .font(.headline)
                                .foregroundStyle(mealColor(mealData.mealType))
                            
                            Text("\(mealData.calories)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(mealColor(mealData.mealType))
                            
                            Text("kcal")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text("\(Int((Double(mealData.calories) / Double(caloriesEaten) * 100).rounded()))%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        } else {
                            Text("Meal Split")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("\(caloriesEaten)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(AppTheme.accentColor)
                        
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
            .frame(height: 200)
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if selectedMeal != nil {
                        selectedMeal = nil
                    } else {
                        showingMealBreakdown.toggle()
                    }
                }
            }
            
            if showingMealBreakdown {
                // Meal breakdown legend
                VStack(spacing: 8) {
                    ForEach(mealBreakdown.filter { $0.calories > 0 }, id: \.mealType) { meal in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                if selectedMeal == meal.mealType {
                                    selectedMeal = nil
                                } else {
                                    selectedMeal = meal.mealType
                                }
                            }
                        } label: {
                            HStack {
                                Circle()
                                    .fill(mealColor(meal.mealType))
                                    .frame(width: 8, height: 8)
                                
                                Text(meal.mealType.rawValue)
                                    .font(.subheadline)
                                    .foregroundStyle(selectedMeal == nil || selectedMeal == meal.mealType ? .primary : .secondary)
                                
                                Spacer()
                                
                                Text("\(meal.calories) kcal")
                                    .font(.subheadline)
                                    .foregroundStyle(selectedMeal == nil || selectedMeal == meal.mealType ? .secondary : .tertiary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
    
    private func startAngle(for meal: (mealType: MealType, calories: Int)) -> Double {
        let activeMeals = mealBreakdown.filter { $0.calories > 0 }
        guard let index = activeMeals.firstIndex(where: { $0.mealType == meal.mealType }) else { return 0 }
        
        let totalCalories = Double(caloriesEaten)
        let previousCalories = activeMeals[..<index].reduce(0) { $0 + Double($1.calories) }
        return previousCalories / totalCalories
    }
    
    private func endAngle(for meal: (mealType: MealType, calories: Int)) -> Double {
        let activeMeals = mealBreakdown.filter { $0.calories > 0 }
        guard let index = activeMeals.firstIndex(where: { $0.mealType == meal.mealType }) else { return 0 }
        
        let totalCalories = Double(caloriesEaten)
        let previousCalories = activeMeals[..<(index + 1)].reduce(0) { $0 + Double($1.calories) }
        return previousCalories / totalCalories
    }
}

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