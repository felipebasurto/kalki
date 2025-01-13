import Foundation
import OSLog

/// Extension of the Logger class to provide logging functionality for different categories.
///
/// - Categories:
///   - health: Logs health-related events and data.
///   - nutrition: Logs nutrition-related events and data.
///   - viewCycle: Logs view lifecycle events.
extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!
    
    static let health = Logger(subsystem: subsystem, category: "health")
    static let nutrition = Logger(subsystem: subsystem, category: "nutrition")
    static let viewCycle = Logger(subsystem: subsystem, category: "views")
    
    /// Logs an error message to the specified category.
    /// - Parameters:
    ///   - message: The error message to log.
    ///   - category: The category to log the error under.
    static func logError(_ message: String, category: Logger) {
        category.error("\(message, privacy: .public)")
    }
} 