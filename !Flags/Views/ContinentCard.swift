import SwiftUI

struct ContinentCard: View {
    let continent: Continent
    
    private var imageName: String {
        switch continent {
        case .europe: return "європа"
        case .asia: return "азія"
        case .northAmerica: return "північна америка"
        case .southAmerica: return "південна америка"
        case .africa: return "африка"
        case .oceania: return "австралія та океанія"
        case .antarctica: return "антарктида"
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                // Фонове зображення континенту
                if let _ = UIImage(named: imageName) {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipped()
                }
                
                // Градієнт
                continent.gradient
                    .opacity(0.7)
                
                // Розмита підложка для кращої читабельності тексту
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.2)
                
                // Контент
                VStack(alignment: .leading, spacing: 8) {
                    Text(continent.countryCount)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
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