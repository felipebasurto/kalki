//
//  kalkiApp.swift
//  kalki
//
//  Created by Felipe Basurto on 2025-01-02.
//

import SwiftUI

@main
struct kalkiApp: App {
    let coreDataManager = CoreDataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    init() {
        Font.registerCustomFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.viewContext)
                .preferredColorScheme(themeManager.currentThemePreference == .system ? nil :
                    themeManager.currentThemePreference == .dark ? .dark : .light)
                .environmentObject(themeManager)
        }
    }
}
