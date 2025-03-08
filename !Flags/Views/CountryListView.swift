import SwiftUI

struct CountryListView: View {
    @StateObject private var countryService = CountryService.shared
    @State private var selectedContinent: Continent = .europe
    
    var body: some View {
        NavigationView {
            List {
                Picker("common.continent".localized, selection: $selectedContinent) {
                    ForEach(Continent.allCases, id: \.self) { continent in
                        Text(continent.localizedName)
                            .tag(continent)
                    }
                }
                .pickerStyle(.menu)
                
                ForEach(countryService.getCountriesForContinent(selectedContinent)) { country in
                    HStack {
                        Text(country.localizedName)
                        Spacer()
                        Text(country.localizedCapital)
                            .foregroundColor(.gray)
                        if country.isIsland {
                            Image(systemName: "water.waves")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("common.countries".localized)
            .onChange(of: selectedContinent) { newContinent in
                print("🌍 Selected continent changed to: \(newContinent)")
                print("📋 Number of countries: \(countryService.getCountriesForContinent(newContinent).count)")
            }
        }
    }
}

#Preview {
    CountryListView()
} 