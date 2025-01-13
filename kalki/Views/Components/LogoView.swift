import SwiftUI

struct LogoView: View {
    var body: some View {
        Text("kalki")
            .font(.custom("Nunito-VariableFont_wght", size: 28, relativeTo: .title))
            .fontWeight(.black)
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(hex: "#4A90E2"), // A nice blue shade
                        Color(hex: "#50E3C2")  // A complementary teal
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .padding(.top, 8)
    }
}

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    LogoView()
} 