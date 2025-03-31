import Foundation

struct QRCode: Identifiable, Codable {
    let id: String
    let content: String
    let timestamp: Date
    
    init(id: String = UUID().uuidString,
         content: String,
         timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
    }
}

extension QRCode {
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: timestamp)
    }
    
    var isValidURL: Bool {
        guard let url = URL(string: content) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    var isSecureURL: Bool {
        guard let url = URL(string: content) else { return false }
        return url.scheme == "https"
    }
} 