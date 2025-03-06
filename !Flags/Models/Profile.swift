import Foundation

enum AuthProvider: String, Codable {
    case guest
    case google
    case apple
}

enum UserLevel: String, Codable, CaseIterable {
    case newbie = "Новачок"
    case explorer = "Дослідник"
    case expert = "Експерт"
    case master = "Майстер"
    case guru = "Географ-Гуру"
}

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    var progress: Double // Від 0 до 1
    var isUnlocked: Bool
    let target: Int // Цільове значення для досягнення
    
    static let livingAtlas = Achievement(
        id: "living_atlas",
        title: "Живий Атлас",
        description: "Знаєш 100 країн світу! Ти вже як ходячий географічний довідник!",
        icon: "🗺️",
        progress: 0,
        isUnlocked: false,
        target: 100
    )
    
    static let geographyWitcher = Achievement(
        id: "geography_witcher",
        title: "Відьмак географії",
        description: "Ви підкорили всю Європу! Тепер ви справжній знавець Старого Світу!",
        icon: "🔮",
        progress: 0,
        isUnlocked: false,
        target: CountryService.shared.countries.filter { $0.continent == .europe }.count
    )
    
    static let traveler = Achievement(
        id: "traveler",
        title: "Подорожник",
        description: "Відкрив усі країни Австралії та Океанії! Тепер ти офіційно австралійський бушрейнджер!",
        icon: "🦘",
        progress: 0,
        isUnlocked: false,
        target: CountryService.shared.countries.filter { $0.continent == .oceania }.count
    )
    
    static let seaConqueror = Achievement(
        id: "sea_conqueror",
        title: "Завойовник морів",
        description: "Ви вивчили всю Африку! Від Сахари до мису Доброї Надії!",
        icon: "🌊",
        progress: 0,
        isUnlocked: false,
        target: CountryService.shared.countries.filter { $0.continent == .africa }.count
    )
    
    static let cartographySherlock = Achievement(
        id: "cartography_sherlock",
        title: "Шерлок картографії",
        description: "Ви розкрили всі таємниці Азії! Від Близького Сходу до Далекого!",
        icon: "🕵️‍♂️",
        progress: 0,
        isUnlocked: false,
        target: CountryService.shared.countries.filter { $0.continent == .asia }.count
    )
    
    static let alienTourist = Achievement(
        id: "alien_tourist",
        title: "Позаземний турист",
        description: "Відкрив усі країни світу (195/195)! Здається, тобі вже варто вивчати країни на Марсі!",
        icon: "🛸",
        progress: 0,
        isUnlocked: false,
        target: 195
    )
    
    static let dailyChallenge = Achievement(
        id: "daily_challenge",
        title: "Щоденний виклик",
        description: "Заходь у додаток 7 днів поспіль!",
        icon: "🎯",
        progress: 0,
        isUnlocked: false,
        target: 7
    )
    
    static let all: [Achievement] = [
        livingAtlas,
        geographyWitcher,
        traveler,
        seaConqueror,
        cartographySherlock,
        alienTourist,
        dailyChallenge
    ]
}

struct Profile: Codable {
    var id: String
    var name: String
    var email: String?
    var phoneNumber: String?
    var dateOfBirth: Date?
    var avatarName: String
    var authProvider: AuthProvider
    var isPro: Bool
    var level: UserLevel
    var achievements: [Achievement]
    
    // Нові поля для відстеження прогресу
    var knownCountries: Set<String>
    var unknownCountries: Set<String>
    var completedContinents: Set<String>
    var visitedCountries: Set<String>
    
    // Статистика
    var correctAnswersStreak: Int
    var maxCorrectAnswersStreak: Int
    var capitalGuessCount: Int?
    var silhouetteGuessCount: Int?
    var lastLoginDate: Date?
    var createdAt: Date
    var updatedAt: Date
    
    // Обчислювані властивості
    var progress: Double {
        let totalCountries = 195.0 // Загальна кількість країн у світі
        return Double(knownCountries.count) / totalCountries
    }
    
    // Функція для перевірки, чи знає користувач країну
    func knowsCountry(_ countryId: String) -> Bool {
        return knownCountries.contains(countryId)
    }
    
    // Функція для перевірки, чи завершений континент
    func hasCompletedContinent(_ continentId: String) -> Bool {
        return completedContinents.contains(continentId)
    }
    
    static func createGuest() -> Profile {
        Profile(
            id: UUID().uuidString,
            name: "Гість",
            email: nil,
            phoneNumber: nil,
            dateOfBirth: nil,
            avatarName: "😊",
            authProvider: .guest,
            isPro: false,
            level: .newbie,
            achievements: Achievement.all,
            knownCountries: [],
            unknownCountries: [],
            completedContinents: [],
            visitedCountries: [],
            correctAnswersStreak: 0,
            maxCorrectAnswersStreak: 0,
            capitalGuessCount: 0,
            silhouetteGuessCount: 0,
            lastLoginDate: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    mutating func update(with profile: Profile) {
        self.name = profile.name
        self.email = profile.email
        self.phoneNumber = profile.phoneNumber
        self.dateOfBirth = profile.dateOfBirth
        self.avatarName = profile.avatarName
        self.isPro = profile.isPro
        self.level = profile.level
        self.achievements = profile.achievements
        self.knownCountries = profile.knownCountries
        self.unknownCountries = profile.unknownCountries
        self.completedContinents = profile.completedContinents
        self.visitedCountries = profile.visitedCountries
        self.correctAnswersStreak = profile.correctAnswersStreak
        self.maxCorrectAnswersStreak = profile.maxCorrectAnswersStreak
        self.capitalGuessCount = profile.capitalGuessCount
        self.silhouetteGuessCount = profile.silhouetteGuessCount
        self.lastLoginDate = profile.lastLoginDate
        self.updatedAt = Date()
    }
} 