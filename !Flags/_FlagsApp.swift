import SwiftUI

@main
struct _FlagsApp: App {
    private let profileService = ProfileService.shared
    private let authService = AuthService.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(profileService)
                .environmentObject(authService)
        }
    }
} 