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

class CountryService: ObservableObject {
    @Published private(set) var countries: [Country] = []
    @Published private(set) var continents: [Continent] = Continent.allCases
    
    static let shared = CountryService()
    
    private init() {
        loadCountries()
    }
    
    private func loadCountries() {
        Logger.shared.info("log.countries.loading_start".localized)
        
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "json") else {
            Logger.shared.error("log.countries.file_not_found".localized)
            return
        }
        
        Logger.shared.debug(String(format: "log.countries.file_found".localized, url.path))
        
        do {
            let data = try Data(contentsOf: url)
            print("📦 JSON data size: \(data.count) bytes")
            print("📄 JSON content: \(String(data: data, encoding: .utf8) ?? "Unable to convert to string")")
            
            let response = try JSONDecoder().decode(CountriesResponse.self, from: data)
            var allCountries: [Country] = []
            
            if let europeCountries = response.europe {
                Logger.shared.debug(String(format: "log.countries.added_europe".localized, europeCountries.count))
                allCountries.append(contentsOf: europeCountries)
            }
            
            if let asiaCountries = response.asia {
                Logger.shared.debug(String(format: "log.countries.added_asia".localized, asiaCountries.count))
                allCountries.append(contentsOf: asiaCountries)
            }
            
            if let africaCountries = response.africa {
                print("🌍 Found \(africaCountries.count) African countries")
                print("📊 Total number of African countries: \(africaCountries.count)")
                africaCountries.forEach { country in
                    print("🏳️ African country: \(country.name)")
                }
                Logger.shared.debug(String(format: "log.countries.added_africa".localized, africaCountries.count))
                allCountries.append(contentsOf: africaCountries)
            } else {
                print("❌ No African countries found in JSON")
            }
            
            if let oceaniaCountries = response.oceania {
                Logger.shared.debug(String(format: "log.countries.added_oceania".localized, oceaniaCountries.count))
                allCountries.append(contentsOf: oceaniaCountries)
            }
            
            if let northAmericaCountries = response.northAmerica {
                Logger.shared.debug(String(format: "log.countries.added_north_america".localized, northAmericaCountries.count))
                allCountries.append(contentsOf: northAmericaCountries)
            }
            
            if let southAmericaCountries = response.southAmerica {
                Logger.shared.debug(String(format: "log.countries.added_south_america".localized, southAmericaCountries.count))
                allCountries.append(contentsOf: southAmericaCountries)
            }
            
            if let antarcticaCountries = response.antarctica {
                Logger.shared.debug(String(format: "log.countries.added_antarctica".localized, antarcticaCountries.count))
                allCountries.append(contentsOf: antarcticaCountries)
            }
            
            Logger.shared.debug(String(format: "log.countries.total_count".localized, allCountries.count))
            self.countries = allCountries
        } catch let decodingError as DecodingError {
            print("🚨 JSON Decoding Error: \(decodingError)")
            Logger.shared.error("log.countries.decoding_error".localized)
        } catch {
            print("🚨 General Error: \(error)")
            Logger.shared.error("log.countries.loading_error".localized)
        }
    }
    
    func getCountriesForContinent(_ continent: Continent) -> [Country] {
        return countries.filter { country in
            country.continent == continent
        }
    }
    
    func getCountry(byId id: String) -> Country? {
        Logger.shared.info(String(format: "log.countries.looking_for".localized, id))
        Logger.shared.debug(String(format: "log.countries.total_in_service".localized, countries.count))
        
        let country = countries.first { $0.id == id }
        if let country = country {
            Logger.shared.info(String(format: "log.countries.found_country".localized, country.name))
        } else {
            Logger.shared.error("log.countries.not_found".localized)
        }
        return country
    }
    
    func getCountriesCount(for continent: Continent) -> Int {
        return getCountriesForContinent(continent).count
    }
    
    func getTotalCountriesCount() -> Int {
        return countries.count
    }
    
    func loadCountries(for continent: Continent) async throws -> [Country] {
        Logger.shared.info("log.countries.looking_for_file".localized)
        
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "json") else {
            Logger.shared.error("log.countries.file_not_found_error".localized)
            throw NSError(
                domain: "CountryService",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "error.countries.file_not_found".localized,
                    NSLocalizedFailureReasonErrorKey: "error.countries.file_not_found_reason".localized
                ]
            )
        }
        
        Logger.shared.info(String(format: "log.countries.file_found_at".localized, url.path))
        
        do {
            Logger.shared.info("log.countries.reading_data".localized)
            let data = try Data(contentsOf: url)
            Logger.shared.debug(String(format: "log.countries.data_size".localized, data.count))
            
            Logger.shared.info("log.countries.decoding_json".localized)
            let response = try JSONDecoder().decode(CountriesResponse.self, from: data)
            Logger.shared.info("log.countries.json_decoded".localized)
            
            switch continent {
            case .europe:
                Logger.shared.info("log.countries.filtering_europe".localized)
                return response.europe ?? []
            case .asia:
                return response.asia ?? []
            case .africa:
                return response.africa ?? []
            case .oceania:
                return response.oceania ?? []
            case .northAmerica:
                return response.northAmerica ?? []
            case .southAmerica:
                return response.southAmerica ?? []
            case .antarctica:
                return response.antarctica ?? []
            }
        } catch let decodingError as DecodingError {
            Logger.shared.error("log.countries.decoding_error".localized)
            throw NSError(
                domain: "CountryService",
                code: -2,
                userInfo: [
                    NSLocalizedDescriptionKey: "error.countries.json_decoding".localized,
                    NSLocalizedFailureReasonErrorKey: decodingError.localizedDescription
                ]
            )
        } catch {
            Logger.shared.error("log.countries.loading_error".localized)
            throw NSError(
                domain: "CountryService",
                code: -3,
                userInfo: [
                    NSLocalizedDescriptionKey: "error.countries.file_reading".localized,
                    NSLocalizedFailureReasonErrorKey: error.localizedDescription
                ]
            )
        }
    }
} 