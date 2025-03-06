import SwiftUI

struct GameView: View {
    let continent: Continent
    @StateObject private var gameService = GameService()
    @EnvironmentObject private var profileService: ProfileService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            if let currentCountry = gameService.currentCountry {
                VStack(spacing: 24) {
                    // Прогрес
                    HStack {
                        Text("\(gameService.currentQuestionIndex + 1)/\(gameService.totalQuestions)")
                            .font(.title2.bold())
                        
                        Spacer()
                        
                        Text("Правильно: \(gameService.score)%")
                            .font(.title2.bold())
                    }
                    .padding(.horizontal)
                    
                    // Прапор
                    Image(currentCountry.id)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .shadow(radius: 10)
                    
                    // Варіанти відповідей
                    VStack(spacing: 16) {
                        ForEach(gameService.options, id: \.id) { option in
                            Button {
                                gameService.checkAnswer(option)
                            } label: {
                                HStack {
                                    Text(option.name)
                                        .font(.title3)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if let isCorrect = gameService.selectedAnswer?.isCorrect,
                                       gameService.selectedAnswer?.id == option.id {
                                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .foregroundColor(isCorrect ? .green : .red)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                            }
                            .disabled(gameService.selectedAnswer != nil)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Кнопка "Далі"
                    if gameService.selectedAnswer != nil {
                        Button {
                            if gameService.isGameFinished {
                                profileService.updateScore(for: continent, score: gameService.score)
                                dismiss()
                            } else {
                                gameService.nextQuestion()
                            }
                        } label: {
                            Text(gameService.isGameFinished ? "Завершити" : "Далі")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.accentColor)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal)
                    }
                }
            } else {
                ProgressView()
                    .task {
                        await gameService.startGame(for: continent)
                    }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        GameView(continent: .europe)
    }
} 