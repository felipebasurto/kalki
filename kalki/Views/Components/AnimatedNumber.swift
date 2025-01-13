import SwiftUI

struct AnimatedNumber: View {
    let value: Double
    let format: String
    let font: Font
    let color: Color?
    
    @State private var animatedValue: Double = 0
    @State private var isHighlighted = false
    
    init(
        value: Double,
        format: String = "%.0f",
        font: Font = .body,
        color: Color? = nil
    ) {
        self.value = value
        self.format = format
        self.font = font
        self.color = color
    }
    
    var body: some View {
        Text(String(format: format, animatedValue))
            .font(font)
            .foregroundStyle(color ?? Color.primary)
            .contentTransition(.numericText())
            .overlay {
                if isHighlighted {
                    Text(String(format: format, animatedValue))
                        .font(font)
                        .foregroundStyle(color ?? Color.primary)
                        .opacity(0.3)
                }
            }
            .onChange(of: value) { oldValue, newValue in
                // Highlight effect
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHighlighted = true
                }
                
                // Animate number
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    animatedValue = newValue
                }
                
                // Remove highlight
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHighlighted = false
                    }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    animatedValue = value
                }
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        AnimatedNumber(
            value: 1234,
            font: .title.bold()
        )
        
        AnimatedNumber(
            value: 98.5,
            format: "%.1f",
            font: .title2,
            color: .blue
        )
    }
} 