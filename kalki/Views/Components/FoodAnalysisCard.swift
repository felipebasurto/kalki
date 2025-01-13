import SwiftUI

struct FoodAnalysisCard: View {
    let food: Food
    @Environment(\.colorScheme) private var colorScheme
    
    public init(food: Food) {
        self.food = food
    }
    
    private var nutrientColor: Color {
        colorScheme == .dark ? .white : Color("PrimaryBlue")
    }
    
    private var mealTypeEmoji: String {
        switch food.mealType {
        case .breakfast: return "☕️"
        case .lunch: return "🥪"
        case .dinner: return "🍛"
        case .snacks: return "🍎"
        }
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color("PrimaryBlue"))
                    
                    Text("\(mealTypeEmoji) \(food.mealType.rawValue)")
                        .font(.subheadline)
                        .foregroundStyle(Color("PrimaryBlue").opacity(0.8))
                }
                
                Spacer()
                
                Text("\(Int(food.calories))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.accentColor)
                + Text(" kcal")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.accentColor.opacity(0.8))
            }
            
            // Nutrients
            HStack {
                NutrientCircle(
                    value: Int(food.carbs),
                    unit: "g",
                    title: "Carbs",
                    color: AppTheme.highlightColor
                )
                
                Spacer()
                
                NutrientCircle(
                    value: Int(food.protein),
                    unit: "g",
                    title: "Protein",
                    color: AppTheme.accentColor
                )
                
                Spacer()
                
                NutrientCircle(
                    value: Int(food.fats),
                    unit: "g",
                    title: "Fats",
                    color: AppTheme.successColor
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color("PrimaryBlue").opacity(0.2), lineWidth: 1)
        }
    }
}

private struct NutrientCircle: View {
    let value: Int
    let unit: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                VStack(spacing: 0) {
                    Text("\(value)")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                    Text(unit)
                        .font(.system(.caption, design: .rounded))
                }
                .foregroundStyle(color)
            }
            
            Text(title)
                .font(.caption)
                .foregroundStyle(color)
        }
    }
} 