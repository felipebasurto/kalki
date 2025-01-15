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
        
        // Configure launch performance metrics
        if #available(iOS 15.0, *) {
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            scene?.keyWindow?.layer.speed = 1.0
        }
        
        // Optimize Core Animation during launch
        CATransaction.setDisableActions(true)
        defer { CATransaction.setDisableActions(false) }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.viewContext)
                .preferredColorScheme(themeManager.currentThemePreference == .system ? nil :
                    themeManager.currentThemePreference == .dark ? .dark : .light)
                .environmentObject(themeManager)
                .onAppear {
                    // Reset CA transaction state after initial render
                    CATransaction.setDisableActions(false)
                }
        }
    }
}
