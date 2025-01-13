import SwiftUI

struct ConfettiView: View {
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<50) { index in
                    ConfettiPiece(
                        color: colors[index % colors.count],
                        size: CGSize(width: 8, height: 8),
                        position: CGPoint(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: -20
                        ),
                        finalPosition: CGPoint(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: geometry.size.height + 20
                        ),
                        rotation: Double.random(in: 0...360),
                        delay: Double(index) * 0.05
                    )
                }
            }
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    let size: CGSize
    let position: CGPoint
    let finalPosition: CGPoint
    let rotation: Double
    let delay: Double
    
    @State private var currentPosition: CGPoint
    @State private var currentRotation: Double
    @State private var scale: CGFloat = 1
    
    init(color: Color, size: CGSize, position: CGPoint, finalPosition: CGPoint, rotation: Double, delay: Double) {
        self.color = color
        self.size = size
        self.position = position
        self.finalPosition = finalPosition
        self.rotation = rotation
        self.delay = delay
        _currentPosition = State(initialValue: position)
        _currentRotation = State(initialValue: rotation)
    }
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size.width, height: size.height)
            .scaleEffect(scale)
            .position(currentPosition)
            .rotationEffect(.degrees(currentRotation))
            .onAppear {
                withAnimation(
                    .spring(
                        response: 0.6,
                        dampingFraction: 0.7,
                        blendDuration: 0.3
                    )
                    .delay(delay)
                ) {
                    currentPosition = finalPosition
                    currentRotation += Double.random(in: 180...360)
                    scale = 0
                }
            }
    }
}

#Preview {
    ConfettiView()
        .frame(width: 300, height: 400)
} 