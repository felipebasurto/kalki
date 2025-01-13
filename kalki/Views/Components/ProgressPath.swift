import SwiftUI

struct ProgressPath: View {
    let dates: [Date]
    let progressMap: [Date: DailyProgress]
    let calorieGoal: Double
    let cellSize: CGSize
    let gridColumns: Int
    
    private var successfulDates: [Date] {
        dates.filter { date in
            guard let progress = progressMap[date] else { return false }
            return progress.calories <= calorieGoal
        }
    }
    
    private func position(for date: Date) -> CGPoint {
        guard let index = dates.firstIndex(of: date) else { return .zero }
        let row = index / gridColumns
        let col = index % gridColumns
        
        return CGPoint(
            x: CGFloat(col) * cellSize.width + cellSize.width/2,
            y: CGFloat(row) * cellSize.height + cellSize.height/2
        )
    }
    
    var body: some View {
        Canvas { context, size in
            // Draw paths between consecutive successful days
            var currentPath = Path()
            var isDrawing = false
            
            for i in 0..<successfulDates.count-1 {
                let current = successfulDates[i]
                let next = successfulDates[i+1]
                
                // Check if dates are consecutive
                if Calendar.current.isDate(next, equalTo: Calendar.current.date(byAdding: .day, value: 1, to: current)!, toGranularity: .day) {
                    let startPoint = position(for: current)
                    let endPoint = position(for: next)
                    
                    if !isDrawing {
                        currentPath.move(to: startPoint)
                        isDrawing = true
                    }
                    currentPath.addLine(to: endPoint)
                } else {
                    if isDrawing {
                        // Draw the completed path with glow
                        context.stroke(
                            currentPath,
                            with: .color(AppTheme.successColor.opacity(0.8)),
                            lineWidth: 3
                        )
                        
                        // Add outer glow
                        context.stroke(
                            currentPath,
                            with: .color(AppTheme.successColor.opacity(0.3)),
                            lineWidth: 6
                        )
                        
                        // Reset path
                        currentPath = Path()
                        isDrawing = false
                    }
                }
            }
            
            // Draw any remaining path
            if isDrawing {
                context.stroke(
                    currentPath,
                    with: .color(AppTheme.successColor.opacity(0.8)),
                    lineWidth: 3
                )
                context.stroke(
                    currentPath,
                    with: .color(AppTheme.successColor.opacity(0.3)),
                    lineWidth: 6
                )
            }
        }
    }
} 