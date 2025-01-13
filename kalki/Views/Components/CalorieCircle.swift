import SwiftUI

public struct CalorieCircle: View {
    let caloriesEaten: Int
    let caloriesBurned: Int
    let calorieGoal: Int
    let mealBreakdown: [(mealType: MealType, calories: Int)]
    
    @State private var showingMealBreakdown = false
    @State private var selectedMealType: MealType?
    @Environment(\.colorScheme) private var colorScheme
    
    public init(caloriesEaten: Int, caloriesBurned: Int, calorieGoal: Int, mealBreakdown: [(mealType: MealType, calories: Int)] = []) {
        self.caloriesEaten = caloriesEaten
        self.caloriesBurned = caloriesBurned
        self.calorieGoal = calorieGoal
        self.mealBreakdown = mealBreakdown
    }
    
    private var totalProgress: Double {
        Double(caloriesEaten) / Double(calorieGoal)
    }
    
    private var mealColors: [MealType: Color] = [
        .breakfast: AppTheme.highlightColor,
        .lunch: AppTheme.accentColor,
        .dinner: AppTheme.successColor,
        .snacks: Color("PrimaryBlue")
    ]
    
    private func mealColor(_ mealType: MealType) -> Color {
        if showingMealBreakdown {
            if let selectedMeal = selectedMealType {
                return selectedMeal == mealType ? (mealColors[mealType] ?? .gray) : Color(.systemGray4)
            }
            return mealColors[mealType] ?? .gray
        }
        return AppTheme.accentColor
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(
                        Color(.systemGray6),
                        lineWidth: 20
                    )
                
                if showingMealBreakdown && !mealBreakdown.isEmpty {
                    // Meal breakdown circles
                    ForEach(mealBreakdown.filter { $0.calories > 0 }.indices, id: \.self) { index in
                        let activeMeals = mealBreakdown.filter { $0.calories > 0 }
                        let meal = activeMeals[index]
                        let startAngle = startAngle(for: index, in: activeMeals)
                        let endAngle = endAngle(for: index, in: activeMeals)
                        
                        Circle()
                            .trim(from: startAngle, to: endAngle)
                            .stroke(
                                mealColor(meal.mealType),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
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
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .transition(.opacity)
                }
                
                // Center content
                VStack(spacing: 4) {
                    if showingMealBreakdown {
                        if let selectedMeal = selectedMealType,
                           let mealData = mealBreakdown.first(where: { $0.mealType == selectedMeal }) {
                            Text(mealData.mealType.rawValue)
                                .font(.headline)
                                .foregroundStyle(mealColors[mealData.mealType] ?? .secondary)
                            
                            Text("\(mealData.calories)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(mealColors[mealData.mealType] ?? .secondary)
                            
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
                .transition(.opacity)
            }
            .frame(height: 200)
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if selectedMealType != nil {
                        selectedMealType = nil
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
                                if selectedMealType == meal.mealType {
                                    selectedMealType = nil
                                } else {
                                    selectedMealType = meal.mealType
                                }
                            }
                        } label: {
                            HStack {
                                Circle()
                                    .fill(mealColor(meal.mealType))
                                    .frame(width: 8, height: 8)
                                
                                Text(meal.mealType.rawValue)
                                    .font(.subheadline)
                                    .foregroundStyle(selectedMealType == nil || selectedMealType == meal.mealType ? .primary : .secondary)
                                
                                Spacer()
                                
                                Text("\(meal.calories) kcal")
                                    .font(.subheadline)
                                    .foregroundStyle(selectedMealType == nil || selectedMealType == meal.mealType ? .secondary : .tertiary)
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
    
    private func startAngle(for index: Int, in activeMeals: [(mealType: MealType, calories: Int)]) -> Double {
        let totalCalories = Double(caloriesEaten)
        let previousCalories = activeMeals[..<index].reduce(0) { $0 + Double($1.calories) }
        return previousCalories / totalCalories
    }
    
    private func endAngle(for index: Int, in activeMeals: [(mealType: MealType, calories: Int)]) -> Double {
        let totalCalories = Double(caloriesEaten)
        let previousCalories = activeMeals[..<(index + 1)].reduce(0) { $0 + Double($1.calories) }
        return previousCalories / totalCalories
    }
}

#Preview {
    CalorieCircle(
        caloriesEaten: 3143,
        caloriesBurned: 651,
        calorieGoal: 2500
    )
} 