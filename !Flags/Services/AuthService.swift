import Foundation
import UIKit
import GoogleSignIn
import KeychainSwift

struct GoogleUser {
    let id: String
    let email: String?
    let name: String?
}

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    private let keychain = KeychainSwift()
    @Published var isAuthenticated = false
    @Published private(set) var currentUser: GoogleUser?
    
    private init() {
        checkAuthStatus()
    }
    
    // MARK: - Auth Status
    private func checkAuthStatus() {
        if keychain.get("google_token") != nil {
            Logger.shared.info("Знайдено збережений Google токен")
            // Відновлюємо дані користувача з профілю
            let profile = ProfileService.shared.currentProfile
            if profile.authProvider == .google {
                currentUser = GoogleUser(
                    id: profile.id,
                    email: profile.email,
                    name: profile.name
                )
                isAuthenticated = true
            } else {
                // Якщо профіль не від Google, очищаємо токен
                keychain.delete("google_token")
                currentUser = nil
                isAuthenticated = false
            }
        } else {
            Logger.shared.debug("Токен авторизації не знайдено")
            currentUser = nil
            isAuthenticated = false
        }
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle() async throws -> Profile {
        Logger.shared.info("Починаємо процес входу через Google")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            Logger.shared.error("Не вдалося отримати rootViewController для авторизації")
            throw AuthError.presentationError
        }
        
        Logger.shared.debug("Викликаємо Google Sign In")
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        Logger.shared.info("Успішно отримано результат входу через Google")
        
        // Update current user
        currentUser = GoogleUser(
            id: result.user.userID ?? UUID().uuidString,
            email: result.user.profile?.email,
            name: result.user.profile?.name
        )
        
        // Create profile from Google sign in data
        let profile = try await createProfileFromGoogle(result: result)
        await saveAuthData(profile: profile)
        return profile
    }
    
    private func createProfileFromGoogle(result: GIDSignInResult) async throws -> Profile {
        Logger.shared.info("Створюємо профіль на основі даних Google")
        let token = result.user.accessToken.tokenString
        
        // Save token securely
        keychain.set(token, forKey: "google_token")
        Logger.shared.debug("Токен Google збережено в Keychain")
        
        // Create new profile
        let profile = Profile(
            id: result.user.userID ?? UUID().uuidString,
            name: result.user.profile?.name ?? "Користувач Google",
            email: result.user.profile?.email,
            phoneNumber: nil,
            dateOfBirth: nil,
            avatarName: "🙂",
            authProvider: .google,
            isPro: false,
            level: .newbie,
            achievements: [],
            knownCountries: Set(),
            unknownCountries: Set(),
            completedContinents: Set(),
            visitedCountries: Set(),
            correctAnswersStreak: 0,
            maxCorrectAnswersStreak: 0,
            capitalGuessCount: 0,
            silhouetteGuessCount: 0,
            lastLoginDate: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )
        
        return profile
    }
    
    // MARK: - Auth Data Management
    private func saveAuthData(profile: Profile) async {
        isAuthenticated = true
        ProfileService.shared.updateProfile(profile)
    }
    
    func signOut() {
        Logger.shared.info("Виходимо з облікового запису")
        GIDSignIn.sharedInstance.signOut()
        keychain.delete("google_token")
        currentUser = nil
        isAuthenticated = false
    }
    
    func deleteAccount() async throws {
        // TODO: Send delete request to server
        signOut()
    }
}

// MARK: - Errors
enum AuthError: Error {
    case invalidCredential
    case presentationError
    case serverError
    case unknown
} 