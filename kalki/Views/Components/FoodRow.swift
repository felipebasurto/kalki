import SwiftUI

public struct FoodRow: View {
    let food: Food
    
    public init(food: Food) {
        self.food = food
    }
    
    private var mealTypeEmoji: String {
        switch food.mealType {
        case .breakfast: return "🍳"
        case .lunch: return "🥪"
        case .dinner: return "🍛"
        case .snacks: return "🥕"
        }
    }
    
    private var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    public var body: some View {
        HStack(spacing: 16) {
            // Meal type indicator
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 44, height: 44)
                
                Text(mealTypeEmoji)
                    .font(.title2)
            }
            
            // Food details
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text("\(Int(food.calories)) kcal")
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text("\(Int(food.protein))g protein")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
                
                if let serving = food.servingSize {
                    Text(serving)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Time
            Text(timeFormatter.string(from: food.timestamp))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
} 