//
//  _FlagsApp.swift
//  !Flags
//
//  Created by oakatev on 03.03.2025.
//

import SwiftUI

@main
struct _FlagsApp: App {
    @StateObject private var profileService = ProfileService.shared
    @StateObject private var authService = AuthService.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(profileService)
                .environmentObject(authService)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // Оновлюємо дані при активації застосунку
                profileService.reloadProfile()
            }
        }
    }
} 