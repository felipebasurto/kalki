import SwiftUI

struct LogoView: View {
    var body: some View {
        Image("kalki")
            .resizable()
            .scaledToFit()
            .frame(height: 28)
            .accessibilityLabel("Kalki Logo")
    }
}

#Preview {
    LogoView()
} 