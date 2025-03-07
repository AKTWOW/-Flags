import SwiftUI

struct ContinentCard: View {
    let continent: Continent
    @StateObject private var profileService = ProfileService.shared
    @Binding var showingProUpgrade: Bool
    
    private var imageName: String {
        switch continent {
        case .europe: return "europe"
        case .asia: return "asia"
        case .northAmerica: return "north_america"
        case .southAmerica: return "south_america"
        case .africa: return "africa"
        case .oceania: return "australia_oceania"
        case .antarctica: return "antarctica"
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                // Background continent image
                if let _ = UIImage(named: imageName) {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipped()
                }
                
                // Gradient
                continent.gradient
                    .opacity(0.7)
                
                // Blurred background for better text readability
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.2)
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(continent.countryCount)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if !profileService.currentProfile.isPro && continent != .oceania {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    Text(continent.localizedName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(radius: 8, x: 0, y: 2)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            ContinentCard(continent: .europe, showingProUpgrade: .constant(false))
            ContinentCard(continent: .northAmerica, showingProUpgrade: .constant(false))
            ContinentCard(continent: .southAmerica, showingProUpgrade: .constant(false))
            ContinentCard(continent: .asia, showingProUpgrade: .constant(false))
            ContinentCard(continent: .africa, showingProUpgrade: .constant(false))
            ContinentCard(continent: .oceania, showingProUpgrade: .constant(false))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
} 