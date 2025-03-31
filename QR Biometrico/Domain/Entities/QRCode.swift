import Foundation
import CoreData

struct QRCode: Identifiable {
    let id: UUID
    let content: String
    let timestamp: Date
    
    init(id: UUID = UUID(), content: String, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
    }
}

extension QRCode {
    init(from entity: QRCodeEntity) {
        self.id = entity.id ?? UUID()
        self.content = entity.content ?? ""
        self.timestamp = entity.timestamp ?? Date()
    }
} 