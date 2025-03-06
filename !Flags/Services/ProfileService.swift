import Foundation
import StoreKit

@MainActor
class ProfileService: ObservableObject {
    static let shared = ProfileService()
    
    @Published private(set) var currentProfile: Profile
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: "profile"),
           let profile = try? JSONDecoder().decode(Profile.self, from: data) {
            currentProfile = profile
        } else {
            currentProfile = Profile()
        }
    }
    
    func saveProfile() {
        if let data = try? JSONEncoder().encode(currentProfile) {
            UserDefaults.standard.set(data, forKey: "profile")
        }
    }
    
    func updateName(_ name: String) {
        currentProfile.name = name
        saveProfile()
    }
    
    func updateAvatarName(_ name: String) {
        currentProfile.avatarName = name
        saveProfile()
    }
    
    func updateScore(for continent: Continent, score: Int) {
        currentProfile.scores[continent] = max(currentProfile.scores[continent] ?? 0, score)
        saveProfile()
    }
    
    func resetToGuest() {
        currentProfile = Profile()
        saveProfile()
    }
    
    func checkPurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.productID == StoreService.shared.productId {
                currentProfile.isPro = true
                saveProfile()
                return
            }
        }
        
        currentProfile.isPro = false
        saveProfile()
    }
} 