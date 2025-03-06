import SwiftUI

struct ProUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var profileService = ProfileService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Анімована корона з золотим ефектом
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
                
                // Заголовок
                Text("Отримайте максимум можливостей!")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 4) {
                    Text("Океанія доступна безкоштовно.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Весь світ - лише за $2.99!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
                
                // Переваги
                VStack(alignment: .leading, spacing: 24) {
                    FeatureRow(
                        icon: "globe",
                        color: .blue,
                        title: "Всі континенти",
                        description: "Доступ до всіх країн світу"
                    )
                    
                    FeatureRow(
                        icon: "map.fill",
                        color: .green,
                        title: "Мапа подорожей",
                        description: "Відстежуйте відвідані країни"
                    )
                    
                    FeatureRow(
                        icon: "trophy.fill",
                        color: .orange,
                        title: "Ексклюзивні нагороди",
                        description: "Спеціальні досягнення для PRO"
                    )
                    
                    FeatureRow(
                        icon: "chart.bar.fill",
                        color: .purple,
                        title: "Розширена статистика",
                        description: "Детальна інформація про прогрес"
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Кнопка оновлення
                VStack(spacing: 12) {
                    Button {
                        profileService.upgradeToPro()
                        dismiss()
                    } label: {
                        Text("Оновити зараз – лише $2.99")
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
                    
                    // Гарантія
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                        Text("Разова покупка – без підписок!")
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
                    Button("Закрити") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Іконка з градієнтом
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary.opacity(0.8))
            }
        }
    }
}

#Preview {
    ProUpgradeView()
} 