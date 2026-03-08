import Foundation

@MainActor
class FailureNotice: Identifiable {
    let id: String
    let message: String
    let source: Source
    let timestamp: Date
    var autoRetried: Bool

    nonisolated enum Source: String, Sendable, Codable {
        case ppsr = "PPSR"
        case login = "Login"
    }

    init(message: String, source: Source, autoRetried: Bool = false) {
        self.id = UUID().uuidString
        self.message = message
        self.source = source
        self.timestamp = Date()
        self.autoRetried = autoRetried
    }

    var formattedTime: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: timestamp)
    }
}
