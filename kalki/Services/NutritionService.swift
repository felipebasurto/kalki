import Foundation

/// Protocol defining the interface for nutrition analysis services.
protocol NutritionService {
    /// Analyzes food using basic nutrition data
    func analyzeFood(_ name: String) async throws -> Food
    
    /// Analyzes food using AI-powered detailed analysis
    func analyzeDetailedFood(_ description: String) async throws -> Food
}

/// Mock implementation of the NutritionService protocol for testing purposes.
class MockNutritionService: NutritionService {
    func analyzeFood(_ name: String) async throws -> Food {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return Food(
            name: name,
            calories: Double.random(in: 100...500),
            protein: Double.random(in: 5...30),
            carbs: Double.random(in: 10...50),
            fats: Double.random(in: 5...20),
            timestamp: Date()
        )
    }
    
    func analyzeDetailedFood(_ description: String) async throws -> Food {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return Food(
            name: description,
            calories: 250,
            protein: 12,
            carbs: 15,
            fats: 3,
            servingSize: "1 serving",
            mealType: .snacks
        )
    }
} 