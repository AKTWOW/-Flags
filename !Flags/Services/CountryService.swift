import Foundation

struct CountriesResponse: Codable {
    let europe: [Country]?
    let asia: [Country]?
    let africa: [Country]?
    let oceania: [Country]?
    let northAmerica: [Country]?
    let southAmerica: [Country]?
    let antarctica: [Country]?
}

class CountryService {
    static let shared = CountryService()
    
    private init() {}
    
    func loadCountries(for continent: Continent) async -> [Country] {
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "json") else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let countries = try JSONDecoder().decode([Country].self, from: data)
            return countries.filter { $0.continent == continent }
        } catch {
            print("Error loading countries:", error)
            return []
        }
    }
    
    func getCountriesForContinent(_ continent: Continent) -> [Country] {
        return []
    }
    
    func getCountry(byId id: String) -> Country? {
        return nil
    }
    
    func getCountriesCount(for continent: Continent) -> Int {
        return 0
    }
    
    func getTotalCountriesCount() -> Int {
        return 0
    }
} 