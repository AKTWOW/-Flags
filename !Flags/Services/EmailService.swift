import Foundation

class EmailService: ObservableObject {
    static let shared = EmailService()
    
    private let emailJSPublicKey = "gdiUdGvnJD5LJMwKb"
    private let emailJSPrivateKey = "Oxg5V6pr3PtslhgZGa4fh"
    private let templateID = "template_flags_support"
    private let serviceID = "service_pcfyucw"
    private let supportEmail = "oleksandr.oliinyk.dev@gmail.com"
    
    private init() {}
    
    func sendSupportEmail(email: String, description: String) async throws {
        Logger.shared.info(String(format: "log.email.support_start".localized, email))
        
        let parameters: [String: Any] = [
            "from_email": email,
            "message": description,
            "to_email": supportEmail,
            "app_name": "Flags",
            "user_email": email,
            "subject": "Flags App Support"
        ]
        
        let url = URL(string: "https://api.emailjs.com/api/v1.0/email/send")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(emailJSPrivateKey, forHTTPHeaderField: "X-EmailJS-Key")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148", forHTTPHeaderField: "User-Agent")
        request.setValue("https://api.emailjs.com", forHTTPHeaderField: "Origin")
        request.setValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("same-site", forHTTPHeaderField: "Sec-Fetch-Site")
        
        let body: [String: Any] = [
            "service_id": serviceID,
            "template_id": templateID,
            "user_id": emailJSPublicKey,
            "accessToken": emailJSPrivateKey,
            "template_params": parameters
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                Logger.shared.error("log.email.unexpected_response".localized)
                throw EmailError.unexpectedResponse
            }
            
            if httpResponse.statusCode != 200 {
                let responseString = String(data: data, encoding: .utf8) ?? "No data"
                Logger.shared.error(String(format: "log.email.send_error".localized, httpResponse.statusCode, responseString))
                
                switch httpResponse.statusCode {
                case 400:
                    throw EmailError.invalidRequest
                case 401, 403:
                    throw EmailError.authenticationFailed
                case 429:
                    throw EmailError.tooManyRequests
                case 500...599:
                    throw EmailError.serverError
                default:
                    throw EmailError.sendingFailed
                }
            }
            
            Logger.shared.info("log.email.send_success".localized)
            
        } catch let error as EmailError {
            throw error
        } catch {
            Logger.shared.error(String(format: "log.email.unexpected_error".localized, error.localizedDescription))
            throw EmailError.networkError(error)
        }
    }
}

enum EmailError: Error {
    case sendingFailed
    case invalidRequest
    case authenticationFailed
    case tooManyRequests
    case serverError
    case unexpectedResponse
    case networkError(Error)
    
    var localizedDescription: String {
        switch self {
        case .sendingFailed:
            return "email.error.sending_failed".localized
        case .invalidRequest:
            return "email.error.invalid_request".localized
        case .authenticationFailed:
            return "email.error.auth_failed".localized
        case .tooManyRequests:
            return "email.error.too_many_requests".localized
        case .serverError:
            return "email.error.server_error".localized
        case .unexpectedResponse:
            return "email.error.unexpected_response".localized
        case .networkError(let error):
            return String(format: "email.error.network".localized, error.localizedDescription)
        }
    }
} 