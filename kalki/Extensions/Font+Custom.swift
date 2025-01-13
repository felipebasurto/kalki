import SwiftUI

extension Font {
    static func registerCustomFonts() {
        // Register custom fonts if they exist in the bundle
        if let fontURL = Bundle.main.url(forResource: "Nunito-ExtraBold", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
    }
} 