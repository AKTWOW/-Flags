import SwiftUI
import StoreKit

struct ProUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeService = StoreService.shared
    @State private var isAnimating = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Group {
                if storeService.product == nil {
                    VStack {
                        ProgressView("Завантаження...")
                            .task {
                                await storeService.loadProducts()
                                
                                if storeService.product == nil {
                                    errorMessage = "Не вдалося завантажити інформацію про продукт. Перевірте підключення до інтернету та спробуйте ще раз."
                                    showError = true
                                }
                            }
                    }
                } else {
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
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(
                                    Animation.easeInOut(duration: 1.0)
                                        .repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                        }
                        .padding(.top, 32)
                        .onAppear {
                            isAnimating = true
                        }
                        
                        // Заголовок
                        Text("Отримайте максимум можливостей!")
                            .font(.title.bold())
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 4) {
                            Text("Океанія доступна безкоштовно.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            if let product = storeService.product {
                                Text("Весь світ - лише за \(product.displayPrice)!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
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
                                Task {
                                    await purchase()
                                }
                            } label: {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Оновити зараз – лише \(storeService.product?.displayPrice ?? "$2.99")")
                                            .font(.title3.bold())
                                    }
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
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрити") {
                        dismiss()
                    }
                }
            }
            .alert("Помилка", isPresented: $showError) {
                Button("OK") { }
                if storeService.product == nil {
                    Button("Спробувати ще раз") {
                        Task {
                            await storeService.loadProducts()
                        }
                    }
                }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func purchase() async {
        isLoading = true
        do {
            try await storeService.purchase()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
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