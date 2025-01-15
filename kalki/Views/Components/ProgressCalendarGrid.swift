import SwiftUI

struct ProgressCalendarGrid: View {
    let month: Date
    let progressMap: [Date: DailyProgress]
    let calorieGoal: Double
    let proteinGoal: Double
    @Binding var selectedDate: Date
    let isPartOfStreak: (Date) -> Bool
    
    @State private var cellSize: CGSize = .zero
    @State private var showingMilestone = false
    @State private var milestoneType: MilestoneType = .perfectWeek
    
    private let gridColumns = 7
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    private var dates: [Date] {
        let calendar = Calendar.current
        let monthStart = calendar.startOfMonth(for: month)
        let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!
        let startWeekday = calendar.component(.weekday, from: monthStart)
        let daysInMonth = calendar.component(.day, from: monthEnd)
        
        var dates: [Date] = []
        
        // Add padding days from previous month
        if startWeekday > 1 {
            let previousMonth = calendar.date(byAdding: .month, value: -1, to: monthStart)!
            let daysInPreviousMonth = calendar.component(.day, from: calendar.date(byAdding: DateComponents(month: 1, day: -1), to: previousMonth)!)
            for day in (daysInPreviousMonth - startWeekday + 2)...daysInPreviousMonth {
                if let date = calendar.date(from: calendar.dateComponents([.year, .month], from: previousMonth)).flatMap({ calendar.date(byAdding: .day, value: day - 1, to: $0) }) {
                    dates.append(date)
                }
            }
        }
        
        // Add days of current month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                dates.append(date)
            }
        }
        
        // Add padding days for next month
        let remainingDays = (gridColumns * 6) - dates.count
        if remainingDays > 0 {
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart)!
            for day in 1...remainingDays {
                if let date = calendar.date(from: calendar.dateComponents([.year, .month], from: nextMonth)).flatMap({ calendar.date(byAdding: .day, value: day - 1, to: $0) }) {
                    dates.append(date)
                }
            }
        }
        
        return dates
    }
    
    private func checkMilestones() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check for perfect week
        guard let weekStart = calendar.date(byAdding: .day, value: -6, to: today) else { return }
        
        var allGoalsMet = true
        var currentDate = weekStart
        
        while currentDate <= today {
            if let progress = progressMap[currentDate] {
                if progress.calories > calorieGoal {
                    allGoalsMet = false
                    break
                }
            } else {
                allGoalsMet = false
                break
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        if allGoalsMet {
            milestoneType = .perfectWeek
            showingMilestone = true
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdays.indices, id: \.self) { index in
                    Text(weekdays[index])
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: gridColumns), spacing: 0) {
                ForEach(dates.indices, id: \.self) { index in
                    let date = dates[index]
                    if !Calendar.current.isDate(date, equalTo: month, toGranularity: .month) {
                        Color.clear
                            .aspectRatio(1, contentMode: .fill)
                    } else {
                        CalendarCell(
                            date: date,
                            selectedDate: selectedDate,
                            progress: progressMap[date],
                            calorieGoal: calorieGoal,
                            proteinGoal: proteinGoal,
                            isPartOfStreak: isPartOfStreak(date),
                            onSelect: {
                                if date <= Date() {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedDate = date
                                    }
                                }
                            }
                        )
                        .disabled(date > Date())
                        .background(GeometryReader { proxy in
                            Color.clear.onAppear {
                                cellSize = proxy.size
                            }
                        })
                    }
                }
            }
        }
        .onAppear {
            checkMilestones()
        }
        .onChange(of: month) { _, _ in
            checkMilestones()
        }
        .overlay {
            if showingMilestone {
                MilestoneCelebration(type: milestoneType) {
                    showingMilestone = false
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

private struct CalendarCell: View {
    let date: Date
    let selectedDate: Date
    let progress: DailyProgress?
    let calorieGoal: Double
    let proteinGoal: Double
    let isPartOfStreak: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect, label: {
            ProgressCalendarCell(
                date: date,
                progress: progress,
                calorieGoal: calorieGoal,
                proteinGoal: proteinGoal,
                isPartOfStreak: isPartOfStreak,
                isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate)
            )
        })
        .buttonStyle(.plain)
    }
}

enum MilestoneType {
    case perfectWeek
    case newStreak
    case monthlyGoal
    
    var title: String {
        switch self {
        case .perfectWeek: return "Perfect Week!"
        case .newStreak: return "New Streak Record!"
        case .monthlyGoal: return "Monthly Goal Achieved!"
        }
    }
    
    var icon: String {
        switch self {
        case .perfectWeek: return "star.circle.fill"
        case .newStreak: return "flame.fill"
        case .monthlyGoal: return "trophy.fill"
        }
    }
}

struct MilestoneCelebration: View {
    let type: MilestoneType
    let onDismiss: () -> Void
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
            
            VStack(spacing: 16) {
                Image(systemName: type.icon)
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.highlightColor)
                
                Text(type.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.text.primary)
                
                Button(action: {
                    withAnimation {
                        onDismiss()
                    }
                }, label: {
                    Text("Awesome!")
                })
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.background)
                    .shadow(radius: 20)
            }
        }
        .onAppear {
            withAnimation {
                showConfetti = true
            }
        }
    }
}

private extension Date {
    var dayOfMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
} 
