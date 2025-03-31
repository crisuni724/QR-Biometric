import Foundation
import Security

class KeychainDataSource {
    private let service = "com.kris.qrbiometrico"
    
    func savePin(_ pin: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "pin",
            kSecValueData as String: pin.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }
    
    func getPin() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "pin",
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let pin = String(data: data, encoding: .utf8) else {
            throw KeychainError.itemNotFound
        }
        
        return pin
    }
    
    func deletePin() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "pin"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed
        }
    }
}

enum KeychainError: LocalizedError {
    case saveFailed
    case deleteFailed
    case itemNotFound
    case unknown(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "No se pudo guardar el PIN en el Keychain"
        case .deleteFailed:
            return "No se pudo eliminar el PIN del Keychain"
        case .itemNotFound:
            return "No se encontró el PIN en el Keychain"
        case .unknown(let status):
            return "Error desconocido del Keychain: \(status)"
        }
    }
} 