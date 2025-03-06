import SwiftUI

struct ContinentCard: View {
    let continent: Continent
    @EnvironmentObject private var profileService: ProfileService
    
    var body: some View {
        HStack(spacing: 16) {
            Text(continent.icon)
                .font(.system(size: 48))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(continent.rawValue)
                    .font(.title2.bold())
                
                Text(continent.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let score = profileService.currentProfile.scores[continent.rawValue] {
                    Text("Рекорд: \(score)%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            ContinentCard(continent: .europe)
            ContinentCard(continent: .northAmerica)
            ContinentCard(continent: .southAmerica)
            ContinentCard(continent: .asia)
            ContinentCard(continent: .africa)
            ContinentCard(continent: .oceania)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
} 