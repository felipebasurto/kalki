import SwiftUI

struct AIAnalyzingAnimation: View {
    @State private var currentEmojiIndex = 0
    private let emojis = ["🤔", "🧐", "🔍", "📊", "🧮", "💭"]
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 16) {
            Text(emojis[currentEmojiIndex])
                .font(.system(size: 40))
                .transition(.scale.combined(with: .opacity))
                .id(currentEmojiIndex) // Force transition animation
            
            Text("Analyzing your food...")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            // Bouncing dots
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(.secondary)
                        .frame(width: 8, height: 8)
                        .offset(y: index == currentEmojiIndex % 3 ? -8 : 0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentEmojiIndex)
                }
            }
        }
        .onReceive(timer) { _ in
            withAnimation {
                currentEmojiIndex = (currentEmojiIndex + 1) % emojis.count
            }
        }
    }
} 