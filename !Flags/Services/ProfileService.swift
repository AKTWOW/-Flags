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
            Logger.shared.info("log.profile.loaded".localized)
            self.currentProfile = profile
        } else {
            Logger.shared.info("log.profile.created".localized)
            self.currentProfile = .createGuest()
            self.saveProfile()
        }
    }
    
    func reloadProfile() {
        Logger.shared.info("log.profile.reloading".localized)
        
        if let data = storage.data(forKey: "profile"),
           let profile = try? JSONDecoder().decode(Profile.self, from: data) {
            Logger.shared.debug(String(format: "log.profile.loaded_countries".localized, profile.knownCountries.count))
            
            // Send signal about changes before update
            objectWillChange.send()
            
            self.currentProfile = profile
            
            // Update last login date and check daily streak
            updateLastLoginAndCheckDailyStreak()
            
            // Send another signal after update
            objectWillChange.send()
        } else {
            Logger.shared.error("log.profile.load_failed".localized)
        }
    }
    
    private func saveProfile() {
        Logger.shared.debug("log.profile.saving".localized)
        
        if let encoded = try? JSONEncoder().encode(currentProfile) {
            storage.set(encoded, forKey: "profile")
            storage.synchronize()
        } else {
            Logger.shared.error("log.profile.save_error".localized)
        }
    }
    
    private func checkPurchaseStatus() async {
        do {
            try await AppStore.sync()
            
            var foundActivePurchase = false
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    if transaction.productID == "com.oleksii.flags.premium" {
                        foundActivePurchase = true
                        if !currentProfile.isPro {
                            currentProfile.isPro = true
                            saveProfile()
                        }
                        break
                    }
                }
            }
            
            // Only if no active purchases found and user was Pro
            if !foundActivePurchase && currentProfile.isPro {
                currentProfile.isPro = false
                saveProfile()
            }
        } catch {
            // Only log error, don't change status
            Logger.shared.error(String(format: "log.profile.purchase_error".localized, error.localizedDescription))
            Logger.shared.debug("log.profile.purchase_status".localized)
        }
    }
    
    func signInWithGoogle() {
        // TODO: Implement Google Sign In
        currentProfile.authProvider = .google
        saveProfile()
    }
    
    func updateProfile(_ profile: Profile) {
        Logger.shared.debug("log.profile.updating".localized)
        
        // Save current data
        let currentKnownCountries = currentProfile.knownCountries
        let currentUnknownCountries = currentProfile.unknownCountries
        let currentVisitedCountries = currentProfile.visitedCountries
        let currentIsPro = currentProfile.isPro
        let currentCorrectAnswersStreak = currentProfile.correctAnswersStreak
        let currentMaxCorrectAnswersStreak = currentProfile.maxCorrectAnswersStreak
        
        // Update basic profile data
        currentProfile = profile
        
        // Initialize achievements if empty
        if currentProfile.achievements.isEmpty {
            currentProfile.achievements = Achievement.all
        }
        
        // Restore saved progress
        currentProfile.knownCountries = currentKnownCountries
        currentProfile.unknownCountries = currentUnknownCountries
        currentProfile.visitedCountries = currentVisitedCountries
        currentProfile.isPro = currentIsPro
        currentProfile.correctAnswersStreak = currentCorrectAnswersStreak
        currentProfile.maxCorrectAnswersStreak = currentMaxCorrectAnswersStreak
        
        // Save and update
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
        Logger.shared.info(String(format: "log.profile.marking_known".localized, countryId))
        Logger.shared.debug(String(format: "log.profile.current_known".localized, currentProfile.knownCountries.description))
        
        // Add country only if it wasn't added before
        if !currentProfile.knownCountries.contains(countryId) {
            objectWillChange.send()
            
            // Add to known and remove from unknown
            currentProfile.knownCountries.insert(countryId)
            currentProfile.unknownCountries.remove(countryId)
            
            // Update statistics
            currentProfile.correctAnswersStreak += 1
            currentProfile.maxCorrectAnswersStreak = max(
                currentProfile.maxCorrectAnswersStreak,
                currentProfile.correctAnswersStreak
            )
            
            // Check continent completion
            checkContinentCompletion(for: countryId)
            
            // Save changes
            saveProfile()
            
            // Update achievements and level
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
        Logger.shared.info("log.profile.checking_achievements".localized)
        
        let knownCount = currentProfile.knownCountries.count
        let totalCountries = 195.0
        
        // Living Atlas (100 countries)
        let livingAtlasProgress = Double(knownCount) / 100.0
        updateAchievementProgress(.livingAtlas, livingAtlasProgress)
        Logger.shared.debug(String(format: "log.profile.achievement.living_atlas".localized, livingAtlasProgress * 100, knownCount))
        
        // Alien Tourist (all countries)
        let alienTouristProgress = Double(knownCount) / totalCountries
        updateAchievementProgress(.alienTourist, alienTouristProgress)
        Logger.shared.debug(String(format: "log.profile.achievement.alien_tourist".localized, alienTouristProgress * 100, knownCount))
        
        // Traveler (all Oceania countries)
        let oceaniaCountries = CountryService.shared.countries.filter { $0.continent == .oceania }
        let knownOceaniaCount = oceaniaCountries.filter { currentProfile.knownCountries.contains($0.id) }.count
        let oceaniaProgress = Double(knownOceaniaCount) / Double(oceaniaCountries.count)
        updateAchievementProgress(.traveler, oceaniaProgress)
        Logger.shared.debug(String(format: "log.profile.achievement.traveler".localized, oceaniaProgress * 100, knownOceaniaCount, oceaniaCountries.count))
        
        // Geography Witcher (all Europe countries)
        let europeCountries = CountryService.shared.countries.filter { $0.continent == .europe }
        let knownEuropeCount = europeCountries.filter { currentProfile.knownCountries.contains($0.id) }.count
        let europeProgress = Double(knownEuropeCount) / Double(europeCountries.count)
        updateAchievementProgress(.geographyWitcher, europeProgress)
        Logger.shared.debug(String(format: "log.profile.achievement.geography_witcher".localized, europeProgress * 100, knownEuropeCount, europeCountries.count))
        
        // Sea Conqueror (all Africa countries)
        let africaCountries = CountryService.shared.countries.filter { $0.continent == .africa }
        let knownAfricaCount = africaCountries.filter { currentProfile.knownCountries.contains($0.id) }.count
        let africaProgress = Double(knownAfricaCount) / Double(africaCountries.count)
        updateAchievementProgress(.seaConqueror, africaProgress)
        Logger.shared.debug(String(format: "log.profile.achievement.sea_conqueror".localized, africaProgress * 100, knownAfricaCount, africaCountries.count))
        
        // Cartography Sherlock (all Asia countries)
        let asiaCountries = CountryService.shared.countries.filter { $0.continent == .asia }
        let knownAsiaCount = asiaCountries.filter { currentProfile.knownCountries.contains($0.id) }.count
        let asiaProgress = Double(knownAsiaCount) / Double(asiaCountries.count)
        updateAchievementProgress(.cartographySherlock, asiaProgress)
        Logger.shared.debug(String(format: "log.profile.achievement.cartography_sherlock".localized, asiaProgress * 100, knownAsiaCount, asiaCountries.count))
        
        // Daily Challenge (7 days in a row)
        if let dailyChallenge = currentProfile.achievements.first(where: { $0.id == Achievement.dailyChallenge.id }) {
            let progress = Double(currentProfile.correctAnswersStreak) / Double(dailyChallenge.target)
            updateAchievementProgress(dailyChallenge, progress)
            Logger.shared.debug(String(format: "log.profile.achievement.daily_challenge".localized, progress * 100, currentProfile.correctAnswersStreak))
        }
        
        // Update level based on progress
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
    
    func resetToGuest() async throws {
        Logger.shared.info("log.profile.reset".localized)
        let wasPro = currentProfile.isPro
        currentProfile = .createGuest()
        currentProfile.isPro = wasPro
        saveProfile()
        try await AuthService.shared.signOut()
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
            let products = try await Product.products(for: ["com.oleksii.flags.premium"])
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
    
    func purchasePremium() async throws -> Bool {
        do {
            // Отримуємо продукт
            let products = try await Product.products(for: ["com.oleksii.flags.premium"])
            guard let proProduct = products.first else {
                Logger.shared.error("log.profile.product_not_found".localized)
                return false
            }
            
            // Купуємо продукт
            let result = try await proProduct.purchase()
            
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    // Завершуємо транзакцію
                    await transaction.finish()
                    
                    // Оновлюємо статус
                    currentProfile.isPro = true
                    saveProfile()
                    return true
                }
                return false
                
            case .userCancelled:
                Logger.shared.debug("log.profile.purchase_cancelled".localized)
                return false
                
            case .pending:
                Logger.shared.debug("log.profile.purchase_pending".localized)
                return false
                
            @unknown default:
                return false
            }
        } catch {
            Logger.shared.error(String(format: "log.profile.purchase_error".localized, error.localizedDescription))
            throw error
        }
    }
} 