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
        Logger.shared.info("Починаємо завантаження країн")
        
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "json") else {
            Logger.shared.error("Не вдалося знайти файл countries.json")
            return
        }
        
        Logger.shared.debug("Знайдено файл: \(url.path)")
        
        do {
            let data = try Data(contentsOf: url)
            Logger.shared.debug("Розмір даних: \(data.count) байт")
            
            let decoder = JSONDecoder()
            let response = try decoder.decode(CountriesResponse.self, from: data)
            Logger.shared.info("JSON успішно декодовано")
            
            var allCountries: [Country] = []
            
            if let europeCountries = response.europe {
                Logger.shared.debug("Додано \(europeCountries.count) країн Європи")
                allCountries.append(contentsOf: europeCountries)
            }
            if let asiaCountries = response.asia {
                Logger.shared.debug("Додано \(asiaCountries.count) країн Азії")
                allCountries.append(contentsOf: asiaCountries)
            }
            if let africaCountries = response.africa {
                Logger.shared.debug("Додано \(africaCountries.count) країн Африки")
                allCountries.append(contentsOf: africaCountries)
            }
            if let oceaniaCountries = response.oceania {
                Logger.shared.debug("Додано \(oceaniaCountries.count) країн Океанії")
                allCountries.append(contentsOf: oceaniaCountries)
            }
            if let northAmericaCountries = response.northAmerica {
                Logger.shared.debug("Додано \(northAmericaCountries.count) країн Північної Америки")
                allCountries.append(contentsOf: northAmericaCountries)
            }
            if let southAmericaCountries = response.southAmerica {
                Logger.shared.debug("Додано \(southAmericaCountries.count) країн Південної Америки")
                allCountries.append(contentsOf: southAmericaCountries)
            }
            if let antarcticaCountries = response.antarctica {
                Logger.shared.debug("Додано \(antarcticaCountries.count) країн Антарктиди")
                allCountries.append(contentsOf: antarcticaCountries)
            }
            
            Logger.shared.debug("Загальна кількість країн: \(allCountries.count)")
            self.countries = allCountries
        } catch let decodingError as DecodingError {
            Logger.shared.error("Помилка декодування: \(decodingError)")
        } catch {
            Logger.shared.error("Помилка завантаження: \(error)")
        }
    }
    
    func getCountriesForContinent(_ continent: Continent) -> [Country] {
        return countries.filter { country in
            country.continent == continent
        }
    }
    
    func getCountry(byId id: String) -> Country? {
        Logger.shared.info("Шукаємо країну з id: \(id)")
        Logger.shared.debug("Всього країн в сервісі: \(countries.count)")
        
        let country = countries.first { $0.id == id }
        if let country = country {
            Logger.shared.info("Знайдено країну: \(country.name)")
        } else {
            Logger.shared.error("Країну не знайдено")
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
        Logger.shared.info("Шукаємо файл countries.json")
        
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "json") else {
            Logger.shared.error("Файл не знайдено в бандлі")
            throw NSError(
                domain: "CountryService",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Файл countries.json не знайдено в бандлі",
                    NSLocalizedFailureReasonErrorKey: "Переконайтеся, що файл доданий в проект та включений в Copy Bundle Resources"
                ]
            )
        }
        
        Logger.shared.info("Файл знайдено за шляхом: \(url.path)")
        
        do {
            Logger.shared.info("Читаємо дані з файлу")
            let data = try Data(contentsOf: url)
            Logger.shared.debug("Розмір даних: \(data.count) байт")
            
            Logger.shared.info("Декодуємо JSON")
            let response = try JSONDecoder().decode(CountriesResponse.self, from: data)
            Logger.shared.info("JSON успішно декодовано")
            
            switch continent {
            case .europe:
                Logger.shared.info("Фільтруємо країни Європи")
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
            Logger.shared.error("Помилка декодування: \(decodingError)")
            throw NSError(
                domain: "CountryService",
                code: -2,
                userInfo: [
                    NSLocalizedDescriptionKey: "Помилка декодування JSON",
                    NSLocalizedFailureReasonErrorKey: decodingError.localizedDescription
                ]
            )
        } catch {
            Logger.shared.error("Помилка читання файлу: \(error)")
            throw NSError(
                domain: "CountryService",
                code: -3,
                userInfo: [
                    NSLocalizedDescriptionKey: "Помилка читання файлу",
                    NSLocalizedFailureReasonErrorKey: error.localizedDescription
                ]
            )
        }
    }
} 