import SwiftUI

struct ProUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var profileService = ProfileService.shared
    
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
                
                VStack(spacing: 4) {
                    Text("pro.oceania_free".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("pro.world_price".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
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
                    
                    // Guarantee
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                        Text("pro.one_time_purchase".localized)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common.close".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProUpgradeView()
} 