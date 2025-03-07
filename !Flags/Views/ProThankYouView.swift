import SwiftUI

struct ProThankYouView: View {
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
                Text("Дякуємо, що ви з нами!")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
                Text("Ви маєте повний доступ\nдо всіх континентів")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
                
                // Секретна кнопка скидання PRO
                VStack(spacing: 12) {
                    Button {
                        profileService.resetProStatus()
                        dismiss()
                    } label: {
                        Text("Скинути PRO статус")
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
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProThankYouView()
} 