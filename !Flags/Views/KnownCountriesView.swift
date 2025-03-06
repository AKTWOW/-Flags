import SwiftUI

struct KnownCountriesView: View {
    @StateObject private var profileService = ProfileService.shared
    @StateObject private var countryService = CountryService.shared
    @Environment(\.dismiss) private var dismiss
    
    private var knownCountries: [Country] {
        print("📋 Отримуємо список вивчених країн")
        print("📊 Кількість ID в профілі: \(profileService.currentProfile.knownCountries.count)")
        let countries = profileService.currentProfile.knownCountries.compactMap { countryId in
            print("🔍 Шукаємо країну з ID: \(countryId)")
            let country = countryService.getCountry(byId: countryId)
            if let country = country {
                print("✅ Знайдено країну: \(country.name)")
            } else {
                print("❌ Країну не знайдено для ID: \(countryId)")
            }
            return country
        }.sorted { $0.name < $1.name }
        print("📊 Знайдено \(countries.count) країн")
        return countries
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if knownCountries.isEmpty {
                        Text("Ви ще не вивчили жодної країни")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 20)
                    } else {
                        FlowLayout(spacing: 8) {
                            ForEach(knownCountries) { country in
                                CountryChip(country: country) {
                                    profileService.markCountryAsUnknown(country.id)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Вивчені країни")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CountryChip: View {
    let country: Country
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Image(country.flagImageName)
                .resizable()
                .frame(width: 20, height: 20)
                .clipShape(Circle())
            
            Text(country.name)
                .font(.subheadline)
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        var height: CGFloat = 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
            height = max(height, currentY + rowHeight)
        }
        
        return CGSize(width: maxWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            
            subview.place(
                at: CGPoint(x: currentX, y: currentY),
                proposal: ProposedViewSize(size)
            )
            
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
        }
    }
} 