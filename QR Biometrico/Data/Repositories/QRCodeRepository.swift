import Foundation
import CoreData

enum QRRepositoryError: LocalizedError {
    case saveFailed
    case fetchFailed
    case deleteFailed
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "No se pudo guardar el código QR"
        case .fetchFailed:
            return "No se pudieron obtener los códigos QR"
        case .deleteFailed:
            return "No se pudo eliminar el código QR"
        case .invalidData:
            return "Los datos del código QR no son válidos"
        }
    }
}

protocol QRCodeRepositoryProtocol {
    func saveQRCode(_ code: QRCode) async throws
    func getScannedCodes() async throws -> [QRCode]
    func deleteQRCode(_ code: QRCode) async throws
}

class QRCodeRepository: QRCodeRepositoryProtocol {
    private let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "QRBiometrico")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveQRCode(_ code: QRCode) async throws {
        let context = container.newBackgroundContext()
        
        return try await context.perform {
            let entity = QRCodeEntity(context: context)
            entity.id = code.id
            entity.content = code.content
            entity.timestamp = code.timestamp
            
            do {
                try context.save()
            } catch {
                throw QRRepositoryError.saveFailed
            }
        }
    }
    
    func getScannedCodes() async throws -> [QRCode] {
        let context = container.viewContext
        
        return try await context.perform {
            let request = QRCodeEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \QRCodeEntity.timestamp, ascending: false)]
            
            do {
                let entities = try request.execute()
                return entities.compactMap { entity in
                    guard let id = entity.id,
                          let content = entity.content,
                          let timestamp = entity.timestamp else {
                        return nil
                    }
                    return QRCode(id: id, content: content, timestamp: timestamp)
                }
            } catch {
                throw QRRepositoryError.fetchFailed
            }
        }
    }
    
    func deleteQRCode(_ code: QRCode) async throws {
        let context = container.newBackgroundContext()
        
        return try await context.perform {
            let request = QRCodeEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", code.id as CVarArg)
            
            do {
                let entities = try request.execute()
                entities.forEach { context.delete($0) }
                try context.save()
            } catch {
                throw QRRepositoryError.deleteFailed
            }
        }
    }
} 