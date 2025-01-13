import SwiftUI

struct DayStat: View {
    let value: Int
    let goal: Int
    let unit: String
    let icon: String
    let color: Color
    
    private var progress: Double {
        Double(value) / Double(goal)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 6)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                // Icon and value
                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                    Text("\(value)")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                }
                .foregroundStyle(color)
            }
            .frame(width: 80, height: 80)
            
            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
} 