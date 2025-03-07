import SwiftUI

struct CountryCard: View {
    let country: Country
    @State private var isRevealed = false
    @State private var blurRadius: CGFloat = 10
    let onKnow: () -> Void
    let onDontKnow: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Картка з інформацією
            VStack(spacing: 0) {
                // Прапор зверху
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Image(country.flagImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                
                // Інформація про країну
                ZStack(alignment: .bottom) {
                    VStack(spacing: 32) {
                        // Назва країни
                        Text(country.name)
                            .font(.system(size: 32, weight: .bold))
                            .padding(.top, 24)
                        
                        // Інформація
                        VStack(spacing: 24) {
                            infoRow(
                                icon: "house.fill",
                                color: .blue,
                                title: "Столиця",
                                value: country.capital
                            )
                            
                            infoRow(
                                icon: "person.2.fill",
                                color: .green,
                                title: "Населення",
                                value: country.population
                            )
                            
                            infoRow(
                                icon: "sparkles",
                                color: .orange,
                                title: "Цікавий факт",
                                value: country.funFact
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer()
                    }
                    .blur(radius: isRevealed ? 0 : blurRadius)
                    .onChange(of: isRevealed) { oldValue, newValue in
                        if !newValue {
                            withAnimation(
                                .easeInOut(duration: 2)
                                .repeatForever(autoreverses: true)
                            ) {
                                blurRadius = 20
                            }
                        }
                    }
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 2)
                            .repeatForever(autoreverses: true)
                        ) {
                            blurRadius = 20
                        }
                    }
                    
                    // Кнопка "Докладніше"
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            isRevealed.toggle()
                        }
                    } label: {
                        Text(isRevealed ? "Зрозуміло" : "Дізнатися назву")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                    }
                    .padding(.bottom, 16)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 580)
            .background(Color(.systemBackground))
            .cornerRadius(24)
            .shadow(radius: 20, x: 0, y: 4)
            
            // Кнопки під карткою
            HStack(spacing: 20) {
                actionButton(title: "Не знаю", color: .red) {
                    isRevealed = false
                    onDontKnow()
                }
                
                actionButton(title: "Знаю", color: .accentColor) {
                    isRevealed = false
                    onKnow()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, -8)
    }
    
    private func infoRow(icon: String, color: Color, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Іконка з градієнтом
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 16, weight: .medium))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func actionButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Іконка
                Text(title == "Знаю" ? "👍" : "❌")
                    .font(.system(size: 20))
                
                // Текст
                Text(title)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(width: 160, height: 48)
            .background(color)
            .cornerRadius(12)
            .shadow(radius: 10, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // Стиль кнопки з анімацією
    struct ScaleButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.spring(duration: 0.2, bounce: 0.3), value: configuration.isPressed)
        }
    }
}

#Preview {
    CountryCard(
        country: Country(
            id: "nl",
            name: "Нідерланди",
            capital: "Амстердам",
            population: "17,5 млн",
            continent: .europe,
            isIsland: false,
            flagImageName: "netherlands",
            funFact: "Нідерланди відомі виробництвом тюльпанів"
        ),
        onKnow: {},
        onDontKnow: {}
    )
} 