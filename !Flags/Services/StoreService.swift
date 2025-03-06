import StoreKit

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
            
            self.product = products.first
            Logger.shared.debug("Product loaded successfully: \(product?.displayName ?? "Unknown")")
        } catch {
            Logger.shared.error("StoreService error: \(error.localizedDescription)")
            purchaseError = "Продукт тимчасово недоступний"
        }
        isLoading = false
    }
    
    func purchase() async throws {
        guard let product = product else {
            throw StoreError.productNotAvailable
        }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await ProfileService.shared.checkPurchaseStatus()
            
        case .userCancelled:
            throw StoreError.userCancelled
            
        case .pending:
            throw StoreError.pending
            
        @unknown default:
            throw StoreError.unknown
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
    case productNotAvailable
    case userCancelled
    case pending
    case unknown
    case noPurchasesToRestore
    
    var errorDescription: String? {
        switch self {
        case .productNotAvailable:
            return "Продукт недоступний. Спробуйте пізніше."
        case .userCancelled:
            return "Покупку скасовано."
        case .pending:
            return "Покупка в очікуванні."
        case .unknown:
            return "Сталася невідома помилка. Спробуйте пізніше."
        case .noPurchasesToRestore:
            return "Немає покупок для відновлення"
        }
    }
}

extension StoreService {
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.unknown
        case .verified(let safe):
            return safe
        }
    }
} 