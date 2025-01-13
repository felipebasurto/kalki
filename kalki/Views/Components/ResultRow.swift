import SwiftUI

struct ResultRow: View {
    let label: String
    let value: Int
    let unit: String
    let description: String
    let color: Color
    @State private var appeared = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(AppTheme.text.secondary)
            
            HStack {
                Text("\(value)")
                    .font(.title2.bold())
                    .foregroundStyle(color)
                    .contentTransition(.numericText())
                Text(unit)
                    .font(.headline)
                    .foregroundStyle(AppTheme.text.secondary)
            }
            .scaleEffect(appeared ? 1 : 0.8)
            .opacity(appeared ? 1 : 0)
            
            Text(description)
                .font(.caption)
                .foregroundStyle(AppTheme.text.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                appeared = true
            }
        }
    }
} 