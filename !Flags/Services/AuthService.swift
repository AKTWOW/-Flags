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
            Logger.shared.info("log.auth.token_found".localized)
            // Restore user data from profile
            let profile = ProfileService.shared.currentProfile
            if profile.authProvider == .google {
                currentUser = GoogleUser(
                    id: profile.id,
                    email: profile.email,
                    name: profile.name
                )
                isAuthenticated = true
            } else {
                // If profile is not from Google, clear token
                keychain.delete("google_token")
                currentUser = nil
                isAuthenticated = false
            }
        } else {
            Logger.shared.debug("log.auth.token_not_found".localized)
            currentUser = nil
            isAuthenticated = false
        }
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle() async throws -> Profile {
        Logger.shared.info("log.auth.google_signin_start".localized)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            Logger.shared.error("log.auth.root_view_error".localized)
            throw AuthError.presentationError
        }
        
        Logger.shared.debug("log.auth.google_signin_call".localized)
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        Logger.shared.info("log.auth.google_signin_success".localized)
        
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
        Logger.shared.info("log.auth.creating_profile".localized)
        let token = result.user.accessToken.tokenString
        
        // Save token securely
        keychain.set(token, forKey: "google_token")
        Logger.shared.debug("log.auth.token_saved".localized)
        
        // Create new profile
        let profile = Profile(
            id: result.user.userID ?? UUID().uuidString,
            name: result.user.profile?.name ?? "User Google",
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
        Logger.shared.info("log.auth.signout".localized)
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
    case presentationError
    case googleSignInError
    case tokenMissing
    case userCancelled
    case noData
    case invalidCredentials
    
    var localizedDescription: String {
        switch self {
        case .presentationError:
            return "error.auth.presentation".localized
        case .googleSignInError:
            return "error.auth.google_signin".localized
        case .tokenMissing:
            return "error.auth.token_missing".localized
        case .userCancelled:
            return "error.auth.user_cancelled".localized
        case .noData:
            return "error.auth.no_data".localized
        case .invalidCredentials:
            return "error.auth.invalid_credentials".localized
        }
    }
} 