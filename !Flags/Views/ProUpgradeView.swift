import SwiftUI

struct ProUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var profileService = ProfileService.shared
    @State private var showingPrivacyPolicy = false
    @State private var showingTerms = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Animated crown with golden effect
                VStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .yellow.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.top, 32)
                
                // Title
                Text("pro.title".localized)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(spacing: 4) {
                    Text("pro.one_time_purchase".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 8)
                
                // Features
                VStack(alignment: .leading, spacing: 24) {
                    ProFeatureRow(
                        icon: "globe.europe.africa.fill",
                        color: .blue,
                        title: "pro.feature.continents.title".localized,
                        description: "pro.feature.continents.description".localized
                    )
                    
                    ProFeatureRow(
                        icon: "map.fill",
                        color: .green,
                        title: "pro.feature.map.title".localized,
                        description: "pro.feature.map.description".localized
                    )
                    
                    ProFeatureRow(
                        icon: "trophy.fill",
                        color: .orange,
                        title: "pro.feature.rewards.title".localized,
                        description: "pro.feature.rewards.description".localized
                    )
                    
                    ProFeatureRow(
                        icon: "chart.bar.fill",
                        color: .purple,
                        title: "pro.feature.stats.title".localized,
                        description: "pro.feature.stats.description".localized
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 12) {
                    // Upgrade button
                    Button {
                        profileService.upgradeToPro()
                        dismiss()
                    } label: {
                        Text("pro.upgrade_button".localized)
                            .font(.title3.bold())
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
                    
                    // Footer links
                    VStack(spacing: 8) {
                        Button {
                            showingPrivacyPolicy = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.text.fill")
                                    .font(.caption)
                                Text(LocalizedStringKey("privacy.title"))
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        Button {
                            showingTerms = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.text.fill")
                                    .font(.caption)
                                Text(LocalizedStringKey("terms.title"))
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
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
    }
}

private struct ProFeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(color)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ProUpgradeView()
} 