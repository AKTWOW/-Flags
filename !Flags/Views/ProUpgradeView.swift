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
                VStack(spacing: 16) {
                    ProFeatureRow(
                        icon: "globe",
                        title: "pro.feature.continents.title".localized,
                        description: "pro.feature.continents.description".localized,
                        gradient: [Color(hex: "#4158D0"), Color(hex: "#C850C0")]
                    )
                    
                    ProFeatureRow(
                        icon: "map",
                        title: "pro.feature.map.title".localized,
                        description: "pro.feature.map.description".localized,
                        gradient: [Color(hex: "#FF6B6B"), Color(hex: "#FFD93D")]
                    )
                    
                    ProFeatureRow(
                        icon: "star",
                        title: "pro.feature.rewards.title".localized,
                        description: "pro.feature.rewards.description".localized,
                        gradient: [Color(hex: "#00CDAC"), Color(hex: "#8DDC88")]
                    )
                    
                    ProFeatureRow(
                        icon: "chart.bar",
                        title: "pro.feature.stats.title".localized,
                        description: "pro.feature.stats.description".localized,
                        gradient: [Color(hex: "#FF6CAB"), Color(hex: "#7366FF")]
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

struct ProFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let gradient: [Color]
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with gradient background
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: gradient),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
} 