import SwiftUI

@main
struct FlagsApp: App {
    @StateObject private var profileService = ProfileService.shared
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(profileService)
        }
    }
} 