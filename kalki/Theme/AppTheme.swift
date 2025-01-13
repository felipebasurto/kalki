import SwiftUI

/// AppTheme defines the application's theme, including colors and gradients.
enum AppTheme {
    // MARK: - Colors
    static var primaryColor: Color {
        Color("PrimaryBlue")
    }
    
    static var accentColor: Color {
        Color("AccentPink")
    }
    
    static var highlightColor: Color {
        Color("AccentYellow")
    }
    
    static var successColor: Color {
        Color("AccentGreen")
    }
    
    static var purpleColor: Color {
        Color("AccentPurple")
    }
    
    static var orangeColor: Color {
        Color("AccentOrange")
    }
    
    // MARK: - Backgrounds
    static var cardBackground: Color {
        Color(.systemBackground)
    }
    
    static var background: Color {
        Color(.systemBackground)
    }
    
    static var secondaryBackground: Color {
        Color(.secondarySystemBackground)
    }
    
    // MARK: - Text Colors
    struct text {
        static var primary: Color {
            Color(.label)
        }
        
        static var secondary: Color {
            Color(.secondaryLabel)
        }
        
        static var tertiary: Color {
            Color(.tertiaryLabel)
        }
        
        static var onAccent: Color {
            .white
        }
    }
    
    // MARK: - Ring Colors
    struct ringColors {
        /// Inner ring (calories)
        static let primary = Color("AccentPink")
        
        /// Middle ring (protein)
        static let secondary = Color("AccentYellow")
        
        /// Outer ring (exercise)
        static let tertiary = Color("AccentGreen")
    }
    
    // MARK: - UI States
    struct states {
        static var success: Color {
            Color("AccentGreen")
        }
        
        static var attention: Color {
            Color("AccentPink")
        }
        
        static var warning: Color {
            Color("AccentYellow")
        }
        
        static var neutral: Color {
            Color(.systemGray4)
        }
    }
    
    // MARK: - Shadows
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
    
    struct shadows {
        static func cardShadow(isDarkMode: Bool) -> Shadow {
            Shadow(
                color: Color(.systemGray4).opacity(isDarkMode ? 0.3 : 0.2),
                radius: isDarkMode ? 8 : 4,
                x: 0,
                y: isDarkMode ? 4 : 2
            )
        }
        
        static func elevatedShadow(isDarkMode: Bool) -> Shadow {
            Shadow(
                color: Color(.systemGray4).opacity(isDarkMode ? 0.4 : 0.3),
                radius: isDarkMode ? 12 : 6,
                x: 0,
                y: isDarkMode ? 6 : 3
            )
        }
    }
    
    // MARK: - Icons
    static let macroIcons = [
        "calories": "flame.fill",
        "protein": "🥩",
        "carbs": "🍚",
        "fats": "🥑",
        "exercise": "figure.run",
        "weight": "⚖️"
    ]
}

// MARK: - View Modifiers
extension View {
    func cardStyle(isDarkMode: Bool = false) -> some View {
        self
            .padding()
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(
                color: AppTheme.shadows.cardShadow(isDarkMode: isDarkMode).color,
                radius: AppTheme.shadows.cardShadow(isDarkMode: isDarkMode).radius,
                x: AppTheme.shadows.cardShadow(isDarkMode: isDarkMode).x,
                y: AppTheme.shadows.cardShadow(isDarkMode: isDarkMode).y
            )
    }
    
    func elevatedStyle(isDarkMode: Bool = false) -> some View {
        self
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: AppTheme.shadows.elevatedShadow(isDarkMode: isDarkMode).color,
                radius: AppTheme.shadows.elevatedShadow(isDarkMode: isDarkMode).radius,
                x: AppTheme.shadows.elevatedShadow(isDarkMode: isDarkMode).x,
                y: AppTheme.shadows.elevatedShadow(isDarkMode: isDarkMode).y
            )
    }
    
    func primaryButtonStyle() -> some View {
        self
            .padding()
            .background(AppTheme.accentColor)
            .foregroundColor(AppTheme.text.onAccent)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .padding()
            .background(AppTheme.highlightColor)
            .foregroundColor(AppTheme.text.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
} 