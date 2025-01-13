import SwiftUI

struct ProgressCalendarCell: View {
    let date: Date
    let progress: DailyProgress?
    let calorieGoal: Double
    let proteinGoal: Double
    let isPartOfStreak: Bool
    let isSelected: Bool
    
    @AppStorage("hasSeenExerciseAchievement") private var hasSeenExerciseAchievement = false
    @State private var showingAchievementBubble = false
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var progressColor: Color {
        guard let progress = progress, !isToday else { return .clear }
        
        let foodCalories = progress.calories
        
        if foodCalories > calorieGoal {
            // Over food calorie limit
            return AppTheme.states.attention
        } else if foodCalories > 0 {
            // Under food calorie limit
            return AppTheme.successColor
        } else {
            // No food logged
            return AppTheme.accentColor.opacity(0.5)
        }
    }
    
    private var shouldShowGoldBorder: Bool {
        guard let progress = progress, !isToday else { return false }
        // Show gold border only for significant exercise (≥1000 calories)
        return progress.exerciseProgress.activeCalories >= 1000
    }
    
    var body: some View {
        ZStack {
            // Background for progress
            Circle()
                .fill(progressColor)
                .opacity(progress != nil ? 0.2 : 0)
            
            // Selection indicator
            if isSelected {
                Circle()
                    .strokeBorder(AppTheme.accentColor, lineWidth: 2)
            }
            
            // Special border for high exercise achievement
            if shouldShowGoldBorder {
                Circle()
                    .strokeBorder(AppTheme.highlightColor, lineWidth: 2)
            }
            
            // Today indicator
            if isToday {
                Circle()
                    .fill(AppTheme.accentColor.opacity(0.1))
                    .overlay {
                        Circle()
                            .strokeBorder(AppTheme.accentColor, style: StrokeStyle(lineWidth: 1, dash: [2]))
                    }
            }
            
            // Date number
            Text(date.dayOfMonth)
                .font(.system(.body, design: .rounded))
                .fontWeight(isToday ? .bold : .medium)
                .foregroundStyle(progress != nil ? .primary : AppTheme.text.secondary)
            
            // Achievement bubble
            if shouldShowGoldBorder && !hasSeenExerciseAchievement {
                AchievementBubble(text: "Wow! You burned 1000+ calories! 🔥")
                    .offset(y: -50)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            hasSeenExerciseAchievement = true
                        }
                    }
            }
        }
        .frame(width: 40, height: 40)
        .contentShape(Rectangle())
    }
}

struct AchievementBubble: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(AppTheme.highlightColor.opacity(0.2))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(AppTheme.highlightColor)
                    }
            }
            .overlay(alignment: .bottom) {
                // Triangle pointer
                Triangle()
                    .fill(AppTheme.highlightColor)
                    .frame(width: 10, height: 5)
                    .offset(y: 5)
            }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

private extension Date {
    var dayOfMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
} 