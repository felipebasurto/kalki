import SwiftUI

/// GoalRow displays a single goal with its value, unit, and description.
struct GoalRow: View {
    let label: String
    let value: Int
    let unit: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                Text("\(value)")
                    .font(.title3.bold())
                    .foregroundStyle(color)
                Text(unit)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
} 