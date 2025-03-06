import StoreKit
import Foundation

@MainActor
class StoreService: ObservableObject {
    static let shared = StoreService()
    
    let productId = "com.oleksii.flags.premium"
    @Published private(set) var product: Product?
    @Published private(set) var purchaseError: String?
    @Published private(set) var isLoading = false
    
    private init() {
        Task {
            await loadProducts()
        }
    }
    
    func loadProducts() async {
        isLoading = true
        do {
            purchaseError = nil
            Logger.shared.debug("Requesting products for ID: \(productId)")
            
            let products = try await Product.products(for: [productId])
            Logger.shared.debug("Received \(products.count) products")
            
            guard let product = products.first else {
                purchaseError = "Продукт тимчасово недоступний"
                return
            }
            
            self.product = product
            Logger.shared.debug("Product loaded successfully: \(product.displayName)")
        } catch {
            Logger.shared.error("StoreService error: \(error.localizedDescription)")
            purchaseError = "Продукт тимчасово недоступний"
        }
        isLoading = false
    }
    
    func purchase() async throws {
        guard let product = product else {
            throw StoreError.productNotFound
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Перевіряємо транзакцію
                switch verification {
                case .verified(let transaction):
                    // Активуємо преміум
                    await transaction.finish()
                    ProfileService.shared.upgradeToPro()
                    Logger.shared.debug("Purchase successful")
                case .unverified:
                    throw StoreError.verificationFailed
                }
            case .userCancelled:
                throw StoreError.userCancelled
            case .pending:
                throw StoreError.pending
            @unknown default:
                throw StoreError.unknown
            }
        } catch {
            purchaseError = error.localizedDescription
            throw error
        }
    }
    
    func restorePurchases() async throws {
        do {
            try await AppStore.sync()
            
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    if transaction.productID == productId {
                        ProfileService.shared.upgradeToPro()
                        return
                    }
                }
            }
            
            throw StoreError.noPurchasesToRestore
        } catch {
            purchaseError = error.localizedDescription
            throw error
        }
    }
}

enum StoreError: LocalizedError {
    case productNotFound
    case purchaseFailed
    case verificationFailed
    case userCancelled
    case pending
    case noPurchasesToRestore
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Продукт тимчасово недоступний"
        case .purchaseFailed:
            return "Помилка покупки"
        case .verificationFailed:
            return "Помилка верифікації покупки"
        case .userCancelled:
            return "Покупку скасовано"
        case .pending:
            return "Покупка в обробці"
        case .noPurchasesToRestore:
            return "Немає покупок для відновлення"
        case .unknown:
            return "Невідома помилка"
        }
    }
} 