import SwiftUI

@main
struct _FlagsApp: App {
    @StateObject private var profileService = ProfileService.shared
    @StateObject private var authService = AuthService.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(profileService)
                .environmentObject(authService)
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                print("App became active")
            case .inactive:
                print("App became inactive")
            case .background:
                print("App moved to background")
            @unknown default:
                break
            }
        }
    }
}
