import SwiftUI

struct ProgressStat: View {
    let icon: String
    let value: Int
    let target: Int
    let unit: String
    let color: Color
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return Double(value) / Double(target)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .shadow(
                        color: color.opacity(colorScheme == .dark ? 0.5 : 0.3),
                        radius: 2,
                        x: 0,
                        y: 1
                    )
                
                Text("\(value) / \(target) \(unit)")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.text.primary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(colorScheme == .dark ? 0.2 : 0.15))
                        .shadow(
                            color: Color(.systemGray4).opacity(colorScheme == .dark ? 0.3 : 0.2),
                            radius: 1,
                            x: 0,
                            y: 1
                        )
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(colorScheme == .dark ? 1 : 0.8))
                        .frame(width: geometry.size.width * min(progress, 1.0))
                        .shadow(
                            color: color.opacity(colorScheme == .dark ? 0.5 : 0.3),
                            radius: 2,
                            x: 0,
                            y: 1
                        )
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal)
    }
} 