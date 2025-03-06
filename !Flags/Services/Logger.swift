import Foundation

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

final class Logger {
    static let shared = Logger()
    
    private init() {}
    
    #if DEBUG
    private var isEnabled = true
    #else
    private var isEnabled = false
    #endif
    
    func log(_ level: LogLevel, message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard isEnabled else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        let formattedMessage = "\(timestamp) [\(level.rawValue)] [\(fileName):\(line)] \(function): \(message)"
        print(formattedMessage)
    }
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.debug, message: message, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.info, message: message, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.warning, message: message, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, message: message, file: file, function: function, line: line)
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
} 