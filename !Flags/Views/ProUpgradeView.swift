import SwiftUI

struct ProUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var profileService = ProfileService.shared
    @State private var showingPrivacyPolicy = false
    @State private var showingTerms = false
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let isIPad = geometry.size.width > 600
                let contentWidth = isIPad ? min(geometry.size.width * 0.8, 800) : geometry.size.width
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Animated crown with golden effect
                        VStack(spacing: 16) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: isIPad ? 96 : 72))
                                .foregroundStyle(
                                    .linearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .yellow.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.top, isIPad ? 48 : 32)
                        
                        // Title
                        Text("pro.title".localized)
                            .font(isIPad ? .largeTitle.bold() : .title.bold())
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        VStack(spacing: 4) {
                            Text("pro.one_time_purchase".localized)
                                .font(isIPad ? .title3 : .subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 8)
                        
                        // Features
                        VStack(alignment: .leading, spacing: isIPad ? 32 : 24) {
                            ProFeatureRow(
                                icon: "globe.europe.africa.fill",
                                color: .blue,
                                title: "pro.feature.continents.title".localized,
                                description: "pro.feature.continents.description".localized,
                                isIPad: isIPad
                            )
                            
                            ProFeatureRow(
                                icon: "map.fill",
                                color: .green,
                                title: "pro.feature.map.title".localized,
                                description: "pro.feature.map.description".localized,
                                isIPad: isIPad
                            )
                            
                            ProFeatureRow(
                                icon: "trophy.fill",
                                color: .orange,
                                title: "pro.feature.rewards.title".localized,
                                description: "pro.feature.rewards.description".localized,
                                isIPad: isIPad
                            )
                            
                            ProFeatureRow(
                                icon: "chart.bar.fill",
                                color: .purple,
                                title: "pro.feature.stats.title".localized,
                                description: "pro.feature.stats.description".localized,
                                isIPad: isIPad
                            )
                        }
                        .padding(.horizontal, isIPad ? 48 : 16)
                        
                        Spacer(minLength: isIPad ? 48 : 24)
                        
                        VStack(spacing: isIPad ? 16 : 12) {
                            // Upgrade button
                            Button {
                                Task {
                                    isPurchasing = true
                                    do {
                                        if try await profileService.purchasePremium() {
                                            dismiss()
                                        }
                                    } catch {
                                        errorMessage = error.localizedDescription
                                        showError = true
                                    }
                                    isPurchasing = false
                                }
                            } label: {
                                HStack {
                                    if isPurchasing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.trailing, 8)
                                    }
                                    Text("pro.upgrade_button".localized)
                                        .font(isIPad ? .title2.bold() : .title3.bold())
                                }
                                .foregroundColor(.white)
                                .frame(width: isIPad ? 400 : nil)
                                .frame(maxWidth: isIPad ? nil : .infinity)
                                .frame(height: isIPad ? 72 : 64)
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
                            .disabled(isPurchasing)
                            
                            // Footer links
                            VStack(spacing: isIPad ? 12 : 8) {
                                Button {
                                    showingPrivacyPolicy = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "doc.text.fill")
                                            .font(isIPad ? .body : .caption)
                                        Text(LocalizedStringKey("privacy.title"))
                                            .font(isIPad ? .body : .caption)
                                    }
                                    .foregroundColor(.secondary)
                                }
                                
                                Button {
                                    showingTerms = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "doc.text.fill")
                                            .font(isIPad ? .body : .caption)
                                        Text(LocalizedStringKey("terms.title"))
                                            .font(isIPad ? .body : .caption)
                                    }
                                    .foregroundColor(.secondary)
                                }
                            }
                            .padding(.bottom, isIPad ? 32 : 16)
                        }
                        .padding(.horizontal, isIPad ? 0 : 16)
                    }
                    .frame(width: contentWidth)
                }
                .frame(maxWidth: .infinity)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close".localized) {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingTerms) {
            TermsView()
        }
        .alert("pro.error.title".localized, isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}

private struct ProFeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    let isIPad: Bool
    
    var body: some View {
        HStack(spacing: isIPad ? 24 : 16) {
            Circle()
                .fill(color)
                .frame(width: isIPad ? 64 : 48, height: isIPad ? 64 : 48)
                .overlay(
                    Image(systemName: icon)
                        .font(isIPad ? .system(size: 28) : .title2)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: isIPad ? 8 : 4) {
                Text(title)
                    .font(isIPad ? .title3 : .headline)
                Text(description)
                    .font(isIPad ? .body : .subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ProUpgradeView()
} 