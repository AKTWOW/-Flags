import Foundation
import SwiftUI

struct Country: Codable, Identifiable {
    let id: String
    let name: String
    let capital: String
    let population: String
    let continent: Continent
    let isIsland: Bool
    let flagImageName: String
    let funFact: String
    
    // Локалізовані назви
    var localizedName: String {
        // TODO: Implement localization
        return name
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, capital, population, flagImageName, funFact
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        capital = try container.decode(String.self, forKey: .capital)
        population = try container.decode(String.self, forKey: .population)
        flagImageName = try container.decode(String.self, forKey: .flagImageName)
        funFact = try container.decode(String.self, forKey: .funFact)
        
        // Генеруємо id з назви країни
        id = name.lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .folding(options: .diacriticInsensitive, locale: .current)
        
        // Визначаємо континент на основі структури JSON
        let continentString = decoder.codingPath.first?.stringValue ?? "europe"
        switch continentString {
        case "europe": continent = .europe
        case "asia": continent = .asia
        case "northAmerica": continent = .northAmerica
        case "southAmerica": continent = .southAmerica
        case "africa": continent = .africa
        case "oceania": continent = .oceania
        default: continent = .europe
        }
        
        // За замовчуванням встановлюємо isIsland в false
        isIsland = false
    }
    
    // Додаємо ініціалізатор для превью та тестування
    init(id: String = UUID().uuidString,
         name: String,
         capital: String,
         population: String,
         continent: Continent,
         isIsland: Bool = false,
         flagImageName: String,
         funFact: String) {
        self.id = id
        self.name = name
        self.capital = capital
        self.population = population
        self.continent = continent
        self.isIsland = isIsland
        self.flagImageName = flagImageName
        self.funFact = funFact
    }
} 