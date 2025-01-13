import SwiftUI

struct LogoView: View {
    var body: some View {
        Text("kalki")
            .font(.custom("Nunito-ExtraBold", size: 28, relativeTo: .title))
            .foregroundColor(AppTheme.accentColor)
    }
}

#Preview {
    LogoView()
} 