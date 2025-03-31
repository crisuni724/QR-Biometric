import Foundation
import CoreData

class CoreDataQRRepository: QRRepositoryProtocol {
    private let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }
    
    func saveQRCode(_ code: QRCode) async throws {
        let context = coreDataManager.viewContext
        
        let entity = QRCodeEntity(context: context)
        entity.id = code.id
        entity.content = code.content
        entity.timestamp = code.timestamp
        
        coreDataManager.saveContext()
    }
    
    func getAllQRCodes() async throws -> [QRCode] {
        let context = coreDataManager.viewContext
        let request = QRCodeEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \QRCodeEntity.timestamp, ascending: false)]
        
        let entities = try context.fetch(request)
        return entities.map { QRCode(from: $0) }
    }
    
    func deleteQRCode(_ code: QRCode) async throws {
        let context = coreDataManager.viewContext
        let request = QRCodeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", code.id as CVarArg)
        
        let entities = try context.fetch(request)
        entities.forEach { context.delete($0) }
        
        coreDataManager.saveContext()
    }
    
    func getQRCode(byId id: UUID) async throws -> QRCode? {
        let context = coreDataManager.viewContext
        let request = QRCodeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let entities = try context.fetch(request)
        return entities.first.map { QRCode(from: $0) }
    }
} 