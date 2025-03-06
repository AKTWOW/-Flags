import SwiftUI

struct CountryListView: View {
    @StateObject private var countryService = CountryService.shared
    @State private var selectedContinent: Continent = .europe
    
    var body: some View {
        NavigationView {
            List {
                Picker("Континент", selection: $selectedContinent) {
                    ForEach(Continent.allCases, id: \.self) { continent in
                        Text(continent.localizedName)
                            .tag(continent)
                    }
                }
                .pickerStyle(.menu)
                
                ForEach(countryService.getCountriesForContinent(selectedContinent)) { country in
                    HStack {
                        Text(country.name)
                        Spacer()
                        Text(country.capital)
                            .foregroundColor(.gray)
                        if country.isIsland {
                            Image(systemName: "water.waves")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Країни")
        }
    }
}

#Preview {
    CountryListView()
} 