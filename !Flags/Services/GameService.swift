import Foundation

@MainActor
class GameService: ObservableObject {
    @Published private(set) var currentCountry: Country?
    @Published private(set) var options: [Country] = []
    @Published private(set) var selectedAnswer: Answer?
    @Published private(set) var score = 0
    @Published private(set) var currentQuestionIndex = 0
    @Published private(set) var totalQuestions = 0
    @Published private(set) var isGameFinished = false
    
    private var countries: [Country] = []
    private let questionsPerGame = 10
    
    func startGame(for continent: Continent) async {
        countries = await CountryService.shared.loadCountries(for: continent)
        totalQuestions = min(questionsPerGame, countries.count)
        currentQuestionIndex = 0
        score = 0
        isGameFinished = false
        nextQuestion()
    }
    
    func checkAnswer(_ answer: Country) {
        let isCorrect = answer.id == currentCountry?.id
        selectedAnswer = Answer(id: answer.id, name: answer.name, isCorrect: isCorrect)
        
        if isCorrect {
            score = Int((Double(score * currentQuestionIndex + 100) / Double(currentQuestionIndex + 1)).rounded())
        } else {
            score = Int((Double(score * currentQuestionIndex) / Double(currentQuestionIndex + 1)).rounded())
        }
    }
    
    func nextQuestion() {
        currentQuestionIndex += 1
        selectedAnswer = nil
        
        if currentQuestionIndex >= totalQuestions {
            isGameFinished = true
            return
        }
        
        // Вибираємо випадкову країну
        let randomIndex = Int.random(in: 0..<countries.count)
        currentCountry = countries[randomIndex]
        
        // Створюємо масив варіантів відповідей
        var optionsArray = [countries[randomIndex]]
        
        // Додаємо ще 3 випадкові країни
        while optionsArray.count < 4 {
            let randomCountry = countries.randomElement()!
            if !optionsArray.contains(where: { $0.id == randomCountry.id }) {
                optionsArray.append(randomCountry)
            }
        }
        
        // Перемішуємо варіанти відповідей
        options = optionsArray.shuffled()
    }
}

struct Answer {
    let id: String
    let name: String
    let isCorrect: Bool
} 