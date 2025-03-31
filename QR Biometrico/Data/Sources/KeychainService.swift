import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    private let dataSource = KeychainDataSource()
    
    private init() {}
    
    func savePIN(_ pin: String) throws {
        try dataSource.savePin(pin)
    }
    
    func getPIN() throws -> String? {
        try dataSource.getPin()
    }
    
    func deletePIN() throws {
        try dataSource.deletePin()
    }
} 