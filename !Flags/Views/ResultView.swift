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
        case 1: return "країну"
        case 2...4: return "країни"
        default: return "країн"
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Галочка
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.green)
            }
            .confettiCannon(trigger: $counter, num: 50, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200)
            
            // Заголовок
            Text(isPerfectScore ? "Ідеально!" : "Чарівно!")
                .font(.system(size: 32, weight: .bold))
            
            // Підзаголовок
            if isPerfectScore {
                Text("Ви знаєте всі країни \(continent.localizedName)!")
                    .font(.system(size: 17))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
            } else {
                Text("Ви знаєте \(knownCount) \(countriesWord) з \(totalCount) на континенті \(continent.localizedName)")
                    .font(.system(size: 17))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Кнопка продовження
            Button {
                if profileService.currentProfile.isPro {
                    let next = nextContinent
                    onNextContinent(next)
                } else {
                    showingProFeature = true
                }
            } label: {
                HStack {
                    Text("Наступний континент")
                        .font(.system(size: 17, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.blue)
                .cornerRadius(16)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
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