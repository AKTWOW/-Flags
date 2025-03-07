import Foundation
import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private let successGenerator = UINotificationFeedbackGenerator()
    private let errorGenerator = UINotificationFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    
    private init() {
        // Підготовка генераторів
        successGenerator.prepare()
        errorGenerator.prepare()
        impactGenerator.prepare()
        heavyGenerator.prepare()
        lightGenerator.prepare()
    }
    
    func successFeedback() {
        successGenerator.notificationOccurred(.success)
    }
    
    func errorFeedback() {
        // Перший удар
        errorGenerator.notificationOccurred(.error)
        
        // Другий удар через невелику затримку
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.impactGenerator.impactOccurred(intensity: 0.8)
        }
    }
    
    func celebrationFeedback() {
        // Основний "вибух"
        heavyGenerator.impactOccurred(intensity: 1.0)
        
        // Імітація падіння конфетті
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.lightGenerator.impactOccurred(intensity: 0.6)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.lightGenerator.impactOccurred(intensity: 0.4)
        }
    }
} 