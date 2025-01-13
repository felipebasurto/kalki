import Foundation
import SwiftUI

/// ViewModel for managing progress data related to nutrition and exercise.
///
/// - Properties:
///   - selectedDate: The currently selected date for viewing progress.
///   - dailyProgressMap: A map of dates to DailyProgress objects.
///
/// - Methods:
///   - loadProgress: Loads progress data from the food log and exercise service.
///   - getProgress: Retrieves progress data for a specific date.
///   - hasDataForSelectedDate: Checks if there is progress data for the selected date.
@MainActor
class ProgressViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published private(set) var dailyProgressMap: [Date: DailyProgress] = [:]
    @Published var isLoading = false
    
    @AppStorage("dailyExerciseGoal") var dailyExerciseGoal: String = ""
    @AppStorage("dailyCalorieGoal") var dailyCalorieGoal: String = ""
    @AppStorage("dailyProteinGoal") var dailyProteinGoal: String = ""
    
    private let foodLogViewModel: FoodLogViewModel
    private let exerciseService: ExerciseService
    private let maxStoredDays = 30 // Store only last 30 days
    private var loadingTask: Task<Void, Never>?
    private var lastLoadTime: Date?
    private let minimumReloadInterval: TimeInterval = 5 // Minimum seconds between reloads
    
    init(exerciseService: ExerciseService, foodLogViewModel: FoodLogViewModel) {
        self.exerciseService = exerciseService
        self.foodLogViewModel = foodLogViewModel
        loadingTask = Task {
            await loadProgress()
        }
    }
    
    func getProgress(for date: Date) -> DailyProgress? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        return dailyProgressMap[startOfDay]
    }
    
    func refreshProgress() async {
        await loadProgress(forceReload: true)
    }
    
    func loadProgress(forceReload: Bool = false) async {
        // Check if we need to reload
        if !forceReload {
            if let lastLoad = lastLoadTime {
                let timeSinceLastLoad = Date().timeIntervalSince(lastLoad)
                if timeSinceLastLoad < minimumReloadInterval {
                    return
                }
            }
        }
        
        // Cancel any existing loading task
        loadingTask?.cancel()
        
        loadingTask = Task {
            isLoading = true
            defer { 
                isLoading = false
                lastLoadTime = Date()
            }
            
            // Group foods by date
            let calendar = Calendar.current
            let foodsByDate = Dictionary(grouping: foodLogViewModel.foods) { food in
                calendar.startOfDay(for: food.timestamp)
            }
            
            // Get the cutoff date for data cleanup
            let cutoffDate = calendar.date(byAdding: .day, value: -maxStoredDays, to: Date()) ?? Date()
            
            // Calculate progress for each date
            for (date, foods) in foodsByDate {
                if Task.isCancelled { return }
                
                // Skip dates older than cutoff
                guard date >= cutoffDate else { continue }
                
                let calories = foods.reduce(0) { $0 + $1.calories }
                let proteins = foods.reduce(0) { $0 + $1.protein }
                
                // Only update if the data has changed
                let existingProgress = dailyProgressMap[date]
                if existingProgress?.calories != calories || existingProgress?.proteins != proteins {
                    dailyProgressMap[date] = DailyProgress(
                        date: date,
                        calories: calories,
                        proteins: proteins,
                        exerciseProgress: ExerciseProgress(
                            activeCalories: 0,
                            activeCalorieGoal: Double(dailyExerciseGoal) ?? 500,
                            minutes: 0,
                            minutesGoal: 30
                        )
                    )
                }
            }
            
            if !Task.isCancelled {
                // Cleanup old data
                cleanupOldData(before: cutoffDate)
            }
        }
    }
    
    private func cleanupOldData(before date: Date) {
        dailyProgressMap = dailyProgressMap.filter { $0.key >= date }
    }
} 