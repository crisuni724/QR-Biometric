import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private let inMemory: Bool
    
    internal init(inMemory: Bool = false) {
        self.inMemory = inMemory
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "QR_Biometrico")
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error al cargar Core Data: \(error)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error al guardar el contexto: \(error)")
            }
        }
    }
} 