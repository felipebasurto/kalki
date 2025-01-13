import SwiftUI

struct FoodAddedAnimation: View {
    @State private var scale = 0.5
    @State private var opacity = 0.0
    @State private var rotation = -30.0
    let emoji: String
    
    private let emojis = ["🥗", "🥑", "🥩", "🍎", "🥪", "🍜", "🍕", "🥤"]
    
    init(emoji: String? = nil) {
        self.emoji = emoji ?? emojis.randomElement()!
    }
    
    var body: some View {
        Text(emoji)
            .font(.system(size: 60))
            .scaleEffect(scale)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    scale = 1.2
                    opacity = 1
                    rotation = 0
                }
                
                // Scale back down slightly
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.2)) {
                    scale = 1.0
                }
                
                // Fade out and remove
                withAnimation(.easeOut(duration: 0.2).delay(1.0)) {
                    opacity = 0
                    scale = 0.8
                }
            }
    }
} 