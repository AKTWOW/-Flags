import SwiftUI

struct KnownCountriesView: View {
    @StateObject private var profileService = ProfileService.shared
    @StateObject private var countryService = CountryService.shared
    @Environment(\.dismiss) private var dismiss
    
    private var knownCountries: [Country] {
        Logger.shared.info("log.known_countries.getting_list".localized)
        let knownCountryIds = profileService.currentProfile.knownCountries
        Logger.shared.debug("log.known_countries.profile_count".localized(knownCountryIds.count))
        
        var knownCountries: [Country] = []
        
        for id in knownCountryIds {
            Logger.shared.debug("log.known_countries.looking_for".localized(id))
            if let country = countryService.getCountry(byId: id) {
                Logger.shared.debug("log.known_countries.found".localized(country.localizedName))
                knownCountries.append(country)
            } else {
                Logger.shared.error("log.known_countries.not_found".localized(id))
            }
        }
        
        Logger.shared.info("log.known_countries.total_found".localized(knownCountries.count))
        return knownCountries.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if knownCountries.isEmpty {
                        Text("profile.no_countries_learned".localized)
                            .foregroundColor(.secondary)
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
            .navigationTitle("profile.known_countries".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common.done".localized) {
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
            
            Text(country.localizedName)
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