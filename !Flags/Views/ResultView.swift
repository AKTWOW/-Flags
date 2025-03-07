import SwiftUI
import ConfettiSwiftUI

struct ResultView: View {
    let knownCount: Int
    let totalCount: Int
    let continent: Continent
    let onDismiss: () -> Void
    let onNextContinent: (Continent) -> Void
    
    @State private var counter = 0
    @State private var showingProFeature = false
    @StateObject private var profileService = ProfileService.shared
    
    private var isPerfectScore: Bool {
        knownCount == totalCount
    }
    
    private var nextContinent: Continent {
        let availableContinents = Continent.allCases.filter { $0 != continent }
        let randomIndex = Int.random(in: 0..<availableContinents.count)
        return availableContinents[randomIndex]
    }
    
    private var countriesWord: String {
        switch knownCount {
        case 1: return "common.country".localized
        case 2...4: return "common.countries_few".localized
        default: return "common.countries".localized
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Checkmark
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.green)
            }
            .confettiCannon(trigger: $counter, num: 50, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200)
            
            // Title
            Text(isPerfectScore ? "result.perfect".localized : "result.great".localized)
                .font(.system(size: 32, weight: .bold))
            
            // Subtitle
            if isPerfectScore {
                Text("result.know_all_countries".localized([continent.localizedName]))
                    .font(.system(size: 17))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
            } else {
                Text("result.know_count_countries".localized([knownCount, countriesWord, totalCount, continent.localizedName]))
                    .font(.system(size: 17))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Continue button
            Button {
                if profileService.currentProfile.isPro {
                    let next = nextContinent
                    onNextContinent(next)
                } else {
                    showingProFeature = true
                }
            } label: {
                Text("result.next_continent".localized)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.accentColor)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .onAppear {
            if isPerfectScore {
                counter += 1
                HapticManager.shared.celebrationFeedback()
            }
        }
        .sheet(isPresented: $showingProFeature) {
            ProUpgradeView()
        }
    }
}

#Preview {
    ResultView(
        knownCount: 14,
        totalCount: 14,
        continent: .oceania,
        onDismiss: {},
        onNextContinent: { _ in }
    )
} 