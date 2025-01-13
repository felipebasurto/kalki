import Foundation

/// Represents daily progress in terms of calories, proteins, and exercise.
/// - Parameters:
///   - date: The date of the progress.
///   - calories: The number of calories consumed.
///   - proteins: The amount of proteins consumed.
///   - exerciseProgress: The exercise progress details.
struct DailyProgress {
    let date: Date
    let calories: Double
    let proteins: Double
    let exerciseProgress: ExerciseProgress
    
    init(date: Date, calories: Double, proteins: Double, exerciseProgress: ExerciseProgress) {
        precondition(calories >= 0, "Calories cannot be negative")
        precondition(proteins >= 0, "Proteins cannot be negative")
        self.date = date
        self.calories = calories
        self.proteins = proteins
        self.exerciseProgress = exerciseProgress
    }
}

/// Represents exercise progress in terms of active calories and minutes.
/// - Parameters:
///   - activeCalories: The number of active calories burned.
///   - activeCalorieGoal: The goal for active calories.
///   - minutes: The number of active minutes.
///   - minutesGoal: The goal for active minutes.
struct ExerciseProgress {
    let activeCalories: Double
    let activeCalorieGoal: Double
    let minutes: Int
    let minutesGoal: Int
    
    init(activeCalories: Double, activeCalorieGoal: Double, minutes: Int, minutesGoal: Int) {
        precondition(activeCalories >= 0, "Active calories cannot be negative")
        precondition(minutes >= 0, "Minutes cannot be negative")
        self.activeCalories = activeCalories
        self.activeCalorieGoal = activeCalorieGoal
        self.minutes = minutes
        self.minutesGoal = minutesGoal
    }
} 