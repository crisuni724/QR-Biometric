import Foundation
import CoreData

protocol QRCodeRepositoryProtocol {
    func saveQRCode(_ qrCode: QRCode) async throws
    func getAllQRCodes() async throws -> [QRCode]
    func deleteQRCode(_ qrCode: QRCode) async throws
    func updateQRCode(_ qrCode: QRCode) async throws
}

class QRCodeRepository: QRCodeRepositoryProtocol {
    private let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "QR_Biometrico")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveQRCode(_ qrCode: QRCode) async throws {
        let context = container.viewContext
        
        let qrCodeEntity = QRCodeEntity(context: context)
        qrCodeEntity.id = qrCode.id
        qrCodeEntity.content = qrCode.content
        qrCodeEntity.timestamp = qrCode.timestamp
        
        try context.save()
    }
    
    func getAllQRCodes() async throws -> [QRCode] {
        let context = container.viewContext
        let request = QRCodeEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \QRCodeEntity.timestamp, ascending: false)]
        
        let entities = try context.fetch(request)
        return entities.compactMap { entity in
            guard let content = entity.content,
                  let id = entity.id,
                  let timestamp = entity.timestamp else { return nil }
            return QRCode(id: id, content: content, timestamp: timestamp)
        }
    }
    
    func deleteQRCode(_ qrCode: QRCode) async throws {
        let context = container.viewContext
        let request = QRCodeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", qrCode.id as CVarArg)
        
        let entities = try context.fetch(request)
        if let entity = entities.first {
            context.delete(entity)
            try context.save()
        }
    }
    
    func updateQRCode(_ qrCode: QRCode) async throws {
        let context = container.viewContext
        let request = QRCodeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", qrCode.id as CVarArg)
        
        let entities = try context.fetch(request)
        if let entity = entities.first {
            entity.content = qrCode.content
            entity.timestamp = qrCode.timestamp
            try context.save()
        }
    }
} 