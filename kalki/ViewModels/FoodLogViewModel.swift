import Foundation
import CoreData
import SwiftUI

@MainActor
public class FoodLogViewModel: ObservableObject {
    @Published private(set) var foods: [Food] = []
    @Published var shouldShowLogo = true
    private let nutritionService: NutritionService
    private let coreDataManager: CoreDataManager
    
    init(
        nutritionService: NutritionService = MockNutritionService(),
        coreDataManager: CoreDataManager = .shared
    ) {
        self.nutritionService = nutritionService
        self.coreDataManager = coreDataManager
        loadFoods()
    }
    
    private func loadFoods() {
        foods = coreDataManager.fetchFoods()
        objectWillChange.send()
    }
    
    func addFood(_ name: String, mealType: MealType, timestamp: Date) async throws {
        let food = try await nutritionService.analyzeFood(name)
        let updatedFood = Food(
            id: UUID(),
            name: food.name,
            calories: food.calories,
            protein: food.protein,
            carbs: food.carbs,
            fats: food.fats,
            timestamp: timestamp,
            mealType: mealType
        )
        
        if let _ = coreDataManager.createFood(from: updatedFood) {
            foods.append(updatedFood)
            objectWillChange.send()
            NotificationCenter.default.post(name: .foodAdded, object: nil)
        }
    }
    
    func deleteFood(_ food: Food) {
        if let index = foods.firstIndex(where: { $0.id == food.id }) {
            coreDataManager.deleteFood(food)
            foods.remove(at: index)
            objectWillChange.send()
            NotificationCenter.default.post(name: .foodAdded, object: nil)
        }
    }
    
    func updateFood(at index: Int, name: String, calories: Double, protein: Double, carbs: Double, fats: Double, servingSize: String?, mealType: MealType) {
        let food = foods[index]
        let updatedFood = Food(
            id: food.id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            calories: max(0, calories),
            protein: max(0, protein),
            carbs: max(0, carbs),
            fats: max(0, fats),
            servingSize: servingSize?.trimmingCharacters(in: .whitespacesAndNewlines),
            timestamp: food.timestamp,
            mealType: mealType
        )
        
        if let _ = coreDataManager.updateFood(updatedFood) {
            foods[index] = updatedFood
            objectWillChange.send()
            NotificationCenter.default.post(name: .foodAdded, object: nil)
        }
    }
    
    func analyzeFood(_ description: String) async throws -> Food {
        try await nutritionService.analyzeDetailedFood(description)
    }
    
    func updateScrollOffset(_ offset: CGFloat) {
        withAnimation(.easeInOut(duration: 0.2)) {
            shouldShowLogo = offset > -50
        }
    }
} 
