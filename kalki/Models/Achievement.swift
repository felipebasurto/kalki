import Foundation

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let type: AchievementType
    let requirement: Int // Days/calories/etc depending on type
    
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    var progress: Int = 0 // Current progress towards requirement
    
    enum AchievementType: String, Codable, CaseIterable {
        case exercise     // Exercise related (Iron Man, etc)
        case streak      // Streak related (Perfect Week, etc)
        case protein     // Protein goals (Balanced Diet, etc)
        case timing      // Time-based achievements (Early Bird, etc)
        case calories    // Calorie-based achievements
        case special     // Special achievements
        case consistency // Consistency-based achievements
        
        var displayName: String {
            switch self {
            case .exercise:
                return "Exercise"
            case .streak:
                return "Streaks"
            case .protein:
                return "Nutrition"
            case .timing:
                return "Timing"
            case .calories:
                return "Calories"
            case .special:
                return "Special"
            case .consistency:
                return "Consistency"
            }
        }
    }
}

// MARK: - Default Achievements
extension Achievement {
    // Exercise Achievements
    static let ironMan = Achievement(
        id: "iron_man",
        title: "Iron Man",
        description: "Burn 1000+ calories in a single day",
        icon: "figure.run",
        type: .exercise,
        requirement: 1000
    )
    
    static let marathoner = Achievement(
        id: "marathoner",
        title: "Marathoner",
        description: "Burn 1000+ calories for 7 consecutive days",
        icon: "figure.run.circle",
        type: .exercise,
        requirement: 7
    )
    
    // Streak Achievements
    static let perfectWeek = Achievement(
        id: "perfect_week",
        title: "Perfect Week",
        description: "Stay under calorie limit for 7 days straight",
        icon: "star.circle",
        type: .streak,
        requirement: 7
    )
    
    static let perfectMonth = Achievement(
        id: "perfect_month",
        title: "Perfect Month",
        description: "Stay under calorie limit for 30 days straight",
        icon: "star.circle.fill",
        type: .streak,
        requirement: 30
    )
    
    // Protein Achievements
    static let balancedDiet = Achievement(
        id: "balanced_diet",
        title: "Balanced Diet",
        description: "Hit protein goals for 5 days straight",
        icon: "chart.bar",
        type: .protein,
        requirement: 5
    )
    
    static let proteinMaster = Achievement(
        id: "protein_master",
        title: "Protein Master",
        description: "Hit protein goals for 14 days straight",
        icon: "chart.bar.fill",
        type: .protein,
        requirement: 14
    )
    
    // Timing Achievements
    static let earlyBird = Achievement(
        id: "early_bird",
        title: "Early Bird",
        description: "Log breakfast before 9 AM for a week",
        icon: "sunrise",
        type: .timing,
        requirement: 7
    )
    
    static let timekeeper = Achievement(
        id: "timekeeper",
        title: "Timekeeper",
        description: "Log all meals within regular hours for a week",
        icon: "clock",
        type: .timing,
        requirement: 7
    )
    
    // Consistency Achievements
    static let habitFormer = Achievement(
        id: "habit_former",
        title: "Habit Former",
        description: "Log food every day for 21 days",
        icon: "calendar.badge.clock",
        type: .consistency,
        requirement: 21
    )
    
    static let allAchievements: [Achievement] = [
        .ironMan,
        .marathoner,
        .perfectWeek,
        .perfectMonth,
        .balancedDiet,
        .proteinMaster,
        .earlyBird,
        .timekeeper,
        .habitFormer
    ]
}

// MARK: - TODOs
/*
TODO List for Achievement System:

1. Achievement Storage:
   - [ ] Implement UserDefaults storage for achievement progress
   - [ ] Add Codable conformance for persistence
   - [ ] Create migration system for future achievement additions

2. Progress Tracking:
   - [ ] Create AchievementTracker class to monitor progress
   - [ ] Implement progress calculation for each achievement type
   - [ ] Add notifications when achievements are close to completion

3. Achievement Checking:
   - [ ] Add daily achievement check system
   - [ ] Implement real-time achievement monitoring
   - [ ] Create background refresh for achievement progress

4. UI Enhancements:
   - [ ] Add progress bars for incomplete achievements
   - [ ] Create detailed achievement view with progress history
   - [ ] Implement achievement sharing functionality
   - [ ] Add achievement badges to profile view

5. Milestone Celebrations:
   - [ ] Create unique celebration animations for each achievement type
   - [ ] Add sound effects for unlocking achievements
   - [ ] Implement achievement notification system

6. Additional Features:
   - [ ] Add achievement categories/filters
   - [ ] Implement achievement statistics
   - [ ] Create achievement suggestions based on user behavior
   - [ ] Add achievement streaks and combos

7. Social Features:
   - [ ] Add friend comparison for achievements
   - [ ] Implement achievement leaderboards
   - [ ] Create achievement challenges

8. Data Analysis:
   - [ ] Track achievement completion rates
   - [ ] Analyze popular/difficult achievements
   - [ ] Create achievement recommendations

9. Performance:
   - [ ] Optimize achievement checking algorithms
   - [ ] Implement caching for achievement data
   - [ ] Add background processing for achievement updates

10. Testing:
    - [ ] Create unit tests for achievement logic
    - [ ] Add UI tests for achievement interactions
    - [ ] Implement achievement debugging tools
*/ 