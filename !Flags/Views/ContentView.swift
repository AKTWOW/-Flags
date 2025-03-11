import SwiftUI

struct ContentView: View {
    @StateObject private var profileService = ProfileService.shared
    
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
        .environmentObject(ProfileService.shared)
        .environmentObject(AuthService.shared)
} 