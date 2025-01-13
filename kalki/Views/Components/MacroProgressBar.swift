import SwiftUI

struct MacroProgressBar: View {
    let label: String
    let current: Double
    let target: Double
    let color: Color
    
    @State private var animatedCurrent: Double = 0
    @State private var isHighlighted = false
    
    private var progress: Double {
        min(animatedCurrent / target, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Label and current value
            Text(label)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.primary)
            
            Text("\(Int(current))g")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)
            .padding(.vertical, 8)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(label) Progress")
            .accessibilityValue("\(Int(current)) of \(Int(target)) grams")
            
            // Target value
            Text("Target: \(Int(target))g")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .onChange(of: current) { oldValue, newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                animatedCurrent = newValue
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                animatedCurrent = current
            }
        }
    }
}

// MARK: - Preview

struct MacroProgressBarsRow: View {
    struct MacroData {
        let label: String
        let current: Double
        let target: Double
        let color: Color
    }
    
    let macros: [MacroData]
    
    init(macros: [MacroData]) {
        self.macros = macros
    }
    
    var body: some View {
        HStack(spacing: 24) {
            ForEach(Array(macros.enumerated()), id: \.offset) { _, macro in
                MacroProgressBar(
                    label: macro.label,
                    current: macro.current,
                    target: macro.target,
                    color: macro.color
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    VStack {
        MacroProgressBarsRow(macros: [
            .init(label: "Carbs", current: 192, target: 359, color: .orange),
            .init(label: "Protein", current: 110, target: 143, color: .purple),
            .init(label: "Fat", current: 76, target: 96, color: .blue)
        ])
        .padding()
        .background(Color(.systemGroupedBackground))
    }
} 