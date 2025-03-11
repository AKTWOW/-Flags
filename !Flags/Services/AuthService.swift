import Foundation
import UIKit
import GoogleSignIn
import KeychainSwift
import AuthenticationServices

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
    
    // MARK: - Apple Sign In
    func signInWithApple(_ result: Result<ASAuthorization, Error>) async throws -> Profile {
        Logger.shared.info("log.auth.apple_signin_start".localized)
        
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                throw AuthError.invalidCredentials
            }
            
            // Get user identifier
            let userId = appleIDCredential.user
            
            // Get user info if available
            let email = appleIDCredential.email
            let fullName = appleIDCredential.fullName
            let givenName = fullName?.givenName
            let familyName = fullName?.familyName
            let displayName = [givenName, familyName].compactMap { $0 }.joined(separator: " ")
            
            // Save Apple ID token
            if let identityToken = appleIDCredential.identityToken,
               let tokenString = String(data: identityToken, encoding: .utf8) {
                keychain.set(tokenString, forKey: "apple_token")
            }
            
            // Create new profile
            let profile = Profile(
                id: userId,
                name: displayName.isEmpty ? "User Apple" : displayName,
                email: email,
                phoneNumber: nil,
                dateOfBirth: nil,
                avatarName: "🙂",
                authProvider: .apple,
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
            
            // Update current user
            currentUser = GoogleUser(
                id: userId,
                email: email,
                name: displayName
            )
            
            await saveAuthData(profile: profile)
            return profile
            
        case .failure(let error):
            Logger.shared.error("Apple Sign In error: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Auth Data Management
    private func saveAuthData(profile: Profile) async {
        isAuthenticated = true
        ProfileService.shared.updateProfile(profile)
    }
    
    func signOut() async throws {
        Logger.shared.info("log.auth.signout".localized)
        
        // Get current auth provider
        let profile = ProfileService.shared.currentProfile
        
        // Skip for guest
        if profile.authProvider == .guest {
            return
        }
        
        // Show warning and get confirmation
        guard try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Bool, Error>) in
            Task { @MainActor in
                let alert = UIAlertController(
                    title: "profile.edit.signout_warning.title".localized,
                    message: "profile.edit.signout_warning.points".localized + "profile.edit.signout_warning.note".localized,
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "common.cancel".localized, style: .cancel) { _ in
                    continuation.resume(returning: false)
                })
                
                alert.addAction(UIAlertAction(title: "profile.edit.signout".localized, style: .destructive) { _ in
                    continuation.resume(returning: true)
                })
                
                // Present alert
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootViewController = window.rootViewController {
                    rootViewController.present(alert, animated: true)
                } else {
                    continuation.resume(throwing: AuthError.presentationError)
                }
            }
        }) else {
            // User cancelled
            return
        }
        
        try await signOutWithoutConfirmation()
    }
    
    func signOutWithoutConfirmation() async throws {
        // Get current auth provider
        let profile = ProfileService.shared.currentProfile
        
        // Skip for guest
        if profile.authProvider == .guest {
            return
        }
        
        // Sign out based on provider
        switch profile.authProvider {
        case .google:
            GIDSignIn.sharedInstance.signOut()
            keychain.delete("google_token")
        case .apple:
            keychain.delete("apple_token")
        case .guest:
            break
        }
        
        // Reset user state
        currentUser = nil
        isAuthenticated = false
        
        // Reset profile to guest
        try await ProfileService.shared.resetToGuest()
        
        Logger.shared.debug("log.auth.signout_complete".localized)
    }
    
    func deleteAccount() async throws {
        Logger.shared.info("log.auth.delete_account".localized)
        
        // Get current auth provider
        let profile = ProfileService.shared.currentProfile
        let wasPro = profile.isPro  // Зберігаємо статус PRO
        
        // Skip for guest
        if profile.authProvider == .guest {
            return
        }
        
        // Sign out based on provider
        switch profile.authProvider {
        case .google:
            GIDSignIn.sharedInstance.signOut()
            keychain.delete("google_token")
        case .apple:
            keychain.delete("apple_token")
        case .guest:
            break
        }
        
        // Reset user state
        currentUser = nil
        isAuthenticated = false
        
        // Delete all user data
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        
        // Create completely new guest profile
        var guestProfile = Profile.createGuest()
        guestProfile.isPro = wasPro  // Зберігаємо тільки PRO статус
        ProfileService.shared.updateProfile(guestProfile)
        
        Logger.shared.debug("log.auth.delete_account_complete".localized)
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