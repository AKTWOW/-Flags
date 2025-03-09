import SwiftUI

struct ProThankYouView: View {
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
                Text("pro.thank_you.title".localized)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
                Text("pro.thank_you.subtitle".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)
                
                // Features
                VStack(alignment: .leading, spacing: 24) {
                    FeatureRow(
                        icon: "globe.europe.africa.fill",
                        color: .blue,
                        title: "pro.feature.continents.title".localized,
                        description: "pro.feature.continents.description".localized
                    )
                    
                    FeatureRow(
                        icon: "map.fill",
                        color: .green,
                        title: "pro.feature.map.title".localized,
                        description: "pro.feature.map.description".localized
                    )
                    
                    FeatureRow(
                        icon: "trophy.fill",
                        color: .orange,
                        title: "pro.feature.rewards.title".localized,
                        description: "pro.feature.rewards.description".localized
                    )
                    
                    FeatureRow(
                        icon: "chart.bar.fill",
                        color: .purple,
                        title: "pro.feature.stats.title".localized,
                        description: "pro.feature.stats.description".localized
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
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
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common.done".localized) {
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

#Preview {
    ProThankYouView()
} 