import Foundation
import SwiftUI

/// Protocol defining the interface for an exercise service.
///
/// - Methods:
///   - fetchExerciseData: Fetches exercise data for a given date and returns an ExerciseProgress object.
protocol ExerciseService {
    func fetchExerciseData(for date: Date) async throws -> ExerciseProgress
}

enum ExerciseServiceError: Error {
    case networkError
    case invalidDate
    case serverError
}

/// Mock implementation of the ExerciseService protocol for testing purposes.
@MainActor
class MockExerciseService: ObservableObject, ExerciseService {
    @AppStorage("dailyExerciseGoal") private var dailyExerciseGoal = "500"
    
    func fetchExerciseData(for date: Date) async throws -> ExerciseProgress {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let goal = Double(dailyExerciseGoal) ?? 500
        
        return ExerciseProgress(
            activeCalories: 250,
            activeCalorieGoal: goal,
            minutes: 15,
            minutesGoal: 30
        )
    }
} 