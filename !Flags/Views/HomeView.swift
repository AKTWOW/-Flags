import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var profileService: ProfileService
    @State private var showProUpgrade = false
    @State private var showProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(Continent.allCases) { continent in
                        if continent == .oceania || profileService.currentProfile.isPro {
                            NavigationLink {
                                GameView(continent: continent)
                            } label: {
                                ContinentCard(continent: continent)
                            }
                        } else {
                            Button {
                                showProUpgrade = true
                            } label: {
                                ContinentCard(continent: continent)
                                    .overlay {
                                        LockedOverlay()
                                    }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Прапори")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showProUpgrade) {
                ProUpgradeView()
            }
            .sheet(isPresented: $showProfile) {
                NavigationView {
                    EditProfileView()
                }
            }
        }
    }
}

struct LockedOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
            Image(systemName: "lock.fill")
                .font(.system(size: 32))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    HomeView()
} 