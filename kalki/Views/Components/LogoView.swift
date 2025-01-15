import SwiftUI

struct LogoView: View {
    var opacity: Double = 1.0
    
    var body: some View {
        Image("kalki")
            .resizable()
            .scaledToFit()
            .frame(height: 28)
            .opacity(opacity)
            .animation(.easeInOut(duration: 0.2), value: opacity)
            .accessibilityLabel("Kalki Logo")
    }
}

#Preview {
    LogoView()
} 