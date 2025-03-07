import SwiftUI
import GoogleSignIn

struct AuthView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    @StateObject private var profileService = ProfileService.shared
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                        .frame(height: 48)
                    
                    // Animated icon
                    ZStack {
                        // Light shadow under the globe
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#4158D0"), Color(hex: "#C850C0")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .blur(radius: 20)
                            .opacity(0.5)
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#4158D0"), Color(hex: "#C850C0")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .shadow(color: Color(hex: "#4158D0").opacity(0.3), radius: 15)
                        
                        Image(systemName: "globe")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .shadow(color: .white.opacity(0.5), radius: 8)
                    }
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                    .onAppear {
                        isAnimating = true
                    }
                    
                    // Title and subtitle
                    VStack(spacing: 16) {
                        Text("auth.title".localized)
                            .font(.title.bold())
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                        
                        Text("auth.subtitle".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 32)
                    
                    Spacer()
                    
                    // Google sign in button
                    VStack(spacing: 16) {
                        Button {
                            Task {
                                await signInWithGoogle()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image("google_logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text("auth.google_signin".localized)
                                    .font(.title3.bold())
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#4158D0"),
                                        Color(hex: "#C850C0")
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: Color(hex: "#4158D0").opacity(0.3), radius: 10, y: 5)
                        }
                        .disabled(isLoading)
                        
                        // Privacy text
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                            Text("auth.privacy_note".localized)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
            .alert("common.error".localized, isPresented: $showError) {
                Button("common.ok".localized, role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func signInWithGoogle() async {
        isLoading = true
        do {
            let profile = try await authService.signInWithGoogle()
            profileService.updateProfile(profile)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
}

#Preview {
    AuthView()
} 