import SwiftUI

struct HomeView: View {
    @State private var selectedContinent: Continent?
    @State private var showingProfile = false
    @State private var showingProUpgrade = false
    @StateObject private var profileService = ProfileService.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Text("home.choose_continent".localized)
                            .font(.system(size: 34, weight: .bold))
                        
                        Spacer()
                        
                        Button {
                            showingProfile.toggle()
                        } label: {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "#FF6B6B"),
                                            Color(hex: "#FFD93D")
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(profileService.currentProfile.avatarName)
                                        .font(.system(size: 24))
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 44)
                    .padding(.bottom, 16)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Oceania (always available)
                            NavigationLink(value: Continent.oceania) {
                                ContinentCard(continent: .oceania, showingProUpgrade: $showingProUpgrade)
                            }
                            
                            // PRO button
                            if !profileService.currentProfile.isPro {
                                Button {
                                    showingProUpgrade = true
                                } label: {
                                    HStack(alignment: .center, spacing: 16) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack(spacing: 4) {
                                                Text("🔓")
                                                    .font(.title2)
                                                Text("pro.world_price_short".localized)
                                                    .font(.title2.bold())
                                            }
                                            .multilineTextAlignment(.leading)
                                            
                                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                                Text(Continent.oceania.localizedName)
                                                    .fontWeight(.bold) +
                                                Text("pro.unlock_other_continents".localized)
                                            }
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.75))
                                            .lineSpacing(4)
                                            .multilineTextAlignment(.leading)
                                        }
                                        Spacer()
                                        Image(systemName: "crown.fill")
                                            .font(.title2)
                                            .foregroundColor(.yellow)
                                    }
                                    .padding(.vertical, 16)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        ZStack {
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.accentColor.opacity(0.9),
                                                    Color.accentColor
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                            
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    .white.opacity(0.1),
                                                    .clear
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        }
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                                    .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 2)
                                }
                            }
                            
                            // Other continents
                            ForEach(Continent.allCases.filter { $0 != .oceania }, id: \.self) { continent in
                                NavigationLink(value: continent) {
                                    ContinentCard(continent: continent, showingProUpgrade: $showingProUpgrade)
                                }
                                .disabled(!profileService.currentProfile.isPro)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationDestination(for: Continent.self) { continent in
                GameView(continent: continent)
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showingProUpgrade) {
                ProUpgradeView()
            }
            .onAppear {
                profileService.reloadProfile()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    profileService.reloadProfile()
                }
            }
        }
    }
}

#Preview {
    HomeView()
} 