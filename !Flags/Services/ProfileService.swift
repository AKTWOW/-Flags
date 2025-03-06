import Foundation
import SwiftUI
import StoreKit

@MainActor
class ProfileService: ObservableObject {
    static let shared = ProfileService()
    
    @Published private(set) var currentProfile: Profile
    private let storage: UserDefaults
    
    private init() {
        self.storage = UserDefaults.standard
        
        if let data = storage.data(forKey: "profile"),
           let profile = try? JSONDecoder().decode(Profile.self, from: data) {
            Logger.shared.info("Завантажено існуючий профіль")
            self.currentProfile = profile
            
            // Перевіряємо статус покупки при запуску
            Task {
                await checkPurchaseStatus()
            }
        } else {
            Logger.shared.info("Створено новий гостьовий профіль")
            self.currentProfile = .createGuest()
            self.saveProfile()
        }
    }
    
    func reloadProfile() {
        Logger.shared.info("Перезавантаження профілю")
        
        if let data = storage.data(forKey: "profile"),
           let profile = try? JSONDecoder().decode(Profile.self, from: data) {
            Logger.shared.debug("Завантажено \(profile.knownCountries.count) країн")
            
            // Надсилаємо сигнал про зміни перед оновленням
            objectWillChange.send()
            
            self.currentProfile = profile
            
            // Оновлюємо дату останнього входу та перевіряємо щоденний виклик
            updateLastLoginAndCheckDailyStreak()
            
            // Надсилаємо ще один сигнал після оновлення
            objectWillChange.send()
        } else {
            Logger.shared.error("Не вдалося завантажити профіль")
        }
    }
    
    private func saveProfile() {
        Logger.shared.debug("Збереження профілю")
        
        if let encoded = try? JSONEncoder().encode(currentProfile) {
            storage.set(encoded, forKey: "profile")
            storage.synchronize()
        } else {
            Logger.shared.error("Помилка при збереженні профілю")
        }
    }
    
    private func checkPurchaseStatus() async {
        do {
            try await AppStore.sync()
            
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    if transaction.productID == StoreService.shared.productId {
                        currentProfile.isPro = true
                        saveProfile()
                        return
                    }
                }
            }
            // Якщо не знайдено активних покупок - деактивуємо PRO
            currentProfile.isPro = false
            saveProfile()
        } catch {
            Logger.shared.error("Помилка перевірки покупок: \(error.localizedDescription)")
            currentProfile.isPro = false
            saveProfile()
        }
    }
    
    func signInWithGoogle() {
        // TODO: Implement Google Sign In
        currentProfile.authProvider = .google
        saveProfile()
    }
    
    func updateProfile(_ profile: Profile) {
        Logger.shared.debug("Оновлення профілю")
        
        // Зберігаємо поточні дані
        let currentKnownCountries = currentProfile.knownCountries
        let currentUnknownCountries = currentProfile.unknownCountries
        let currentVisitedCountries = currentProfile.visitedCountries
        let currentIsPro = currentProfile.isPro
        let currentCorrectAnswersStreak = currentProfile.correctAnswersStreak
        let currentMaxCorrectAnswersStreak = currentProfile.maxCorrectAnswersStreak
        
        // Оновлюємо базові дані профілю
        currentProfile = profile
        
        // Ініціалізуємо досягнення, якщо вони порожні
        if currentProfile.achievements.isEmpty {
            currentProfile.achievements = Achievement.all
        }
        
        // Відновлюємо збережений прогрес
        currentProfile.knownCountries = currentKnownCountries
        currentProfile.unknownCountries = currentUnknownCountries
        currentProfile.visitedCountries = currentVisitedCountries
        currentProfile.isPro = currentIsPro
        currentProfile.correctAnswersStreak = currentCorrectAnswersStreak
        currentProfile.maxCorrectAnswersStreak = currentMaxCorrectAnswersStreak
        
        // Зберігаємо та оновлюємо
        saveProfile()
        checkAchievements()
        updateLevel()
    }
    
    func updateName(_ name: String) {
        currentProfile.name = name
        saveProfile()
    }
    
    func updateAvatar(_ avatar: String) {
        currentProfile.avatarName = avatar
        saveProfile()
    }
    
    // MARK: - Country Knowledge Management
    func markCountryAsKnown(_ countryId: String) {
        Logger.shared.info("markCountryAsKnown викликано для країни: \(countryId)")
        Logger.shared.debug("Поточні відомі країни: \(currentProfile.knownCountries)")
        
        // Додаємо країну тільки якщо вона ще не була додана
        if !currentProfile.knownCountries.contains(countryId) {
            objectWillChange.send()
            
            // Додаємо до відомих і видаляємо з невідомих
            currentProfile.knownCountries.insert(countryId)
            currentProfile.unknownCountries.remove(countryId)
            
            // Оновлюємо статистику
            currentProfile.correctAnswersStreak += 1
            currentProfile.maxCorrectAnswersStreak = max(
                currentProfile.maxCorrectAnswersStreak,
                currentProfile.correctAnswersStreak
            )
            
            // Перевіряємо завершення континенту
            checkContinentCompletion(for: countryId)
            
            // Зберігаємо зміни
            saveProfile()
            
            // Оновлюємо досягнення та рівень
            checkAchievements()
            updateLevel()
            
            objectWillChange.send()
        }
    }
    
    func markCountryAsUnknown(_ countryId: String) {
        Logger.shared.info("❌ markCountryAsUnknown викликано для країни: \(countryId)")
        
        // Якщо країна була відома, видаляємо її
        if currentProfile.knownCountries.contains(countryId) {
            objectWillChange.send()
            
            // Видаляємо з відомих і додаємо до невідомих
            currentProfile.knownCountries.remove(countryId)
            currentProfile.unknownCountries.insert(countryId)
            currentProfile.correctAnswersStreak = 0
            
            // Перевіряємо статус континенту
            updateContinentStatus(for: countryId)
            
            // Зберігаємо зміни
            saveProfile()
            checkAchievements()
            updateLevel()
            
            objectWillChange.send()
        }
    }
    
    // MARK: - Continent Management
    private func checkContinentCompletion(for countryId: String) {
        // TODO: Implement continent completion check
        // 1. Визначити континент країни
        // 2. Отримати всі країни континенту
        // 3. Перевірити, чи всі вони є у knownCountries
        // 4. Якщо так - додати континент до completedContinents
    }
    
    private func updateContinentStatus(for countryId: String) {
        // TODO: Implement continent status update
        // 1. Визначити континент країни
        // 2. Якщо континент був у completedContinents
        // 3. Перевірити, чи всі інші країни континенту ще відомі
        // 4. Якщо ні - видалити континент з completedContinents
    }
    
    // MARK: - Achievement Management
    private func checkAchievements() {
        Logger.shared.info("Перевіряємо досягнення")
        
        let knownCount = currentProfile.knownCountries.count
        let totalCountries = 195.0
        
        // Живий Атлас (100 країн)
        let livingAtlasProgress = Double(knownCount) / 100.0
        updateAchievementProgress(.livingAtlas, livingAtlasProgress)
        Logger.shared.debug("🗺️ Живий Атлас прогрес: \(livingAtlasProgress * 100)% (\(knownCount)/100 країн)")
        
        // Позаземний турист (всі країни)
        let alienTouristProgress = Double(knownCount) / totalCountries
        updateAchievementProgress(.alienTourist, alienTouristProgress)
        Logger.shared.debug("🛸 Позаземний турист прогрес: \(alienTouristProgress * 100)% (\(knownCount)/195 країн)")
        
        // Подорожник (всі країни Океанії)
        let oceaniaCountries = CountryService.shared.countries.filter { $0.continent == .oceania }
        let knownOceaniaCount = oceaniaCountries.filter { currentProfile.knownCountries.contains($0.id) }.count
        let oceaniaProgress = Double(knownOceaniaCount) / Double(oceaniaCountries.count)
        updateAchievementProgress(.traveler, oceaniaProgress)
        Logger.shared.debug("🦘 Подорожник прогрес: \(oceaniaProgress * 100)% (\(knownOceaniaCount)/\(oceaniaCountries.count) країн)")
        
        // Відьмак географії (всі країни Європи)
        let europeCountries = CountryService.shared.countries.filter { $0.continent == .europe }
        let knownEuropeCount = europeCountries.filter { currentProfile.knownCountries.contains($0.id) }.count
        let europeProgress = Double(knownEuropeCount) / Double(europeCountries.count)
        updateAchievementProgress(.geographyWitcher, europeProgress)
        Logger.shared.debug("🔮 Відьмак географії прогрес: \(europeProgress * 100)% (\(knownEuropeCount)/\(europeCountries.count) країн)")
        
        // Завойовник морів (всі країни Африки)
        let africaCountries = CountryService.shared.countries.filter { $0.continent == .africa }
        let knownAfricaCount = africaCountries.filter { currentProfile.knownCountries.contains($0.id) }.count
        let africaProgress = Double(knownAfricaCount) / Double(africaCountries.count)
        updateAchievementProgress(.seaConqueror, africaProgress)
        Logger.shared.debug("🌊 Завойовник морів прогрес: \(africaProgress * 100)% (\(knownAfricaCount)/\(africaCountries.count) країн)")
        
        // Шерлок картографії (всі країни Азії)
        let asiaCountries = CountryService.shared.countries.filter { $0.continent == .asia }
        let knownAsiaCount = asiaCountries.filter { currentProfile.knownCountries.contains($0.id) }.count
        let asiaProgress = Double(knownAsiaCount) / Double(asiaCountries.count)
        updateAchievementProgress(.cartographySherlock, asiaProgress)
        Logger.shared.debug("🕵️‍♂️ Шерлок картографії прогрес: \(asiaProgress * 100)% (\(knownAsiaCount)/\(asiaCountries.count) країн)")
        
        // Щоденний виклик (7 днів поспіль)
        if let dailyChallenge = currentProfile.achievements.first(where: { $0.id == Achievement.dailyChallenge.id }) {
            let progress = Double(currentProfile.correctAnswersStreak) / Double(dailyChallenge.target)
            updateAchievementProgress(dailyChallenge, progress)
            Logger.shared.debug("🎯 Щоденний виклик прогрес: \(progress * 100)% (\(currentProfile.correctAnswersStreak)/7 днів)")
        }
        
        // Оновлюємо рівень на основі прогресу
        updateLevel()
    }
    
    private func updateLevel() {
        let progress = currentProfile.progress
        let newLevel: UserLevel
        
        switch progress {
        case 0..<0.25:
            newLevel = .newbie
        case 0.25..<0.5:
            newLevel = .explorer
        case 0.5..<0.75:
            newLevel = .expert
        case 0.75..<1.0:
            newLevel = .master
        default:
            newLevel = .guru
        }
        
        if newLevel != currentProfile.level {
            currentProfile.level = newLevel
            saveProfile()
        }
    }
    
    func toggleVisitedCountry(_ countryId: String) {
        if currentProfile.visitedCountries.contains(countryId) {
            currentProfile.visitedCountries.remove(countryId)
        } else {
            currentProfile.visitedCountries.insert(countryId)
        }
        saveProfile()
    }
    
    func upgradeToPro() {
        currentProfile.isPro = true
        saveProfile()
    }
    
    func resetProStatus() {
        currentProfile.isPro = false
        saveProfile()
    }
    
    private func updateAchievementProgress(_ achievement: Achievement, _ progress: Double) {
        if let index = currentProfile.achievements.firstIndex(where: { $0.id == achievement.id }) {
            currentProfile.achievements[index].progress = min(max(progress, 0), 1)
            if progress >= 1 {
                currentProfile.achievements[index].isUnlocked = true
            }
            saveProfile()
        }
    }
    
    private func unlockAchievement(_ achievement: Achievement) {
        if let index = currentProfile.achievements.firstIndex(where: { $0.id == achievement.id }) {
            currentProfile.achievements[index].isUnlocked = true
            saveProfile()
        }
    }
    
    func resetToGuest() {
        currentProfile = .createGuest()
        saveProfile()
    }
    
    private func updateLastLoginAndCheckDailyStreak() {
        let calendar = Calendar.current
        let now = Date()
        
        // Якщо це перший вхід, просто оновлюємо дату
        guard let lastLogin = currentProfile.lastLoginDate else {
            currentProfile.lastLoginDate = now
            saveProfile()
            return
        }
        
        // Перевіряємо, чи це новий день
        if !calendar.isDate(lastLogin, inSameDayAs: now) {
            // Перевіряємо, чи це наступний день
            let isNextDay = calendar.isDate(lastLogin, equalTo: now, toGranularity: .day)
                || calendar.dateComponents([.day], from: lastLogin, to: now).day == 1
            
            if isNextDay {
                // Збільшуємо лічильник щоденних входів
                currentProfile.correctAnswersStreak += 1
                Logger.shared.debug("🎯 Щоденний виклик: \(currentProfile.correctAnswersStreak) днів поспіль")
            } else {
                // Скидаємо лічильник, якщо пропущений день
                currentProfile.correctAnswersStreak = 1
                Logger.shared.debug("🔄 Щоденний виклик скинуто: пропущений день")
            }
            
            // Оновлюємо дату останнього входу
            currentProfile.lastLoginDate = now
            saveProfile()
            
            // Перевіряємо досягнення
            checkAchievements()
        }
    }
    
    func restorePurchases() async -> Bool {
        do {
            // Запускаємо процес відновлення покупок через StoreKit
            let products = try await Product.products(for: ["pro_upgrade"])
            guard let proProduct = products.first else { return false }
            
            // Перевіряємо всі транзакції для цього Apple ID
            for await verification in Transaction.currentEntitlements {
                if case .verified(let transaction) = verification {
                    if transaction.productID == proProduct.id {
                        // Покупка знайдена і верифікована
                        currentProfile.isPro = true
                        saveProfile()
                        return true
                    }
                }
            }
            return false
        } catch {
            Logger.shared.error("Помилка відновлення покупок: \(error.localizedDescription)")
            return false
        }
    }
} 