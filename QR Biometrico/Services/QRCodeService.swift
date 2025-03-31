import Foundation
import AVFoundation

enum QRCodeType {
    case url
    case text
    case wifi
    case contact
    case sms
    case phone
    case email
    case unknown
}

enum QRCodeServiceError: LocalizedError {
    case invalidFormat
    case unsupportedType
    case processingFailed
    case invalidURL
    case invalidWifiConfig
    case invalidContact
    case invalidPhone
    case invalidEmail
    case invalidSMS
    case invalidCharacters
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "El formato del código QR no es válido"
        case .unsupportedType:
            return "El tipo de código QR no es compatible"
        case .processingFailed:
            return "No se pudo procesar el código QR"
        case .invalidURL:
            return "La URL del código QR no es válida"
        case .invalidWifiConfig:
            return "La configuración de WiFi no es válida"
        case .invalidContact:
            return "La información de contacto no es válida"
        case .invalidPhone:
            return "El número de teléfono no es válido"
        case .invalidEmail:
            return "La dirección de correo no es válida"
        case .invalidSMS:
            return "El formato del SMS no es válido"
        case .invalidCharacters:
            return "El código contiene caracteres no permitidos"
        }
    }
}

protocol QRCodeServiceProtocol {
    func processQRCode(_ code: String) async throws -> QRCode
    func validateQRCode(_ code: String) -> Bool
    func detectQRCodeType(_ code: String) -> QRCodeType
}

class QRCodeService: QRCodeServiceProtocol {
    private let repository: QRCodeRepositoryProtocol
    
    init(repository: QRCodeRepositoryProtocol) {
        self.repository = repository
    }
    
    func processQRCode(_ code: String) async throws -> QRCode {
        guard validateQRCode(code) else {
            throw QRCodeServiceError.invalidFormat
        }
        
        let type = detectQRCodeType(code)
        
        switch type {
        case .url:
            try validateURL(code)
        case .wifi:
            try validateWifiConfig(code)
        case .contact:
            try validateContact(code)
        case .phone:
            try validatePhone(code)
        case .email:
            try validateEmail(code)
        case .sms:
            try validateSMS(code)
        case .text, .unknown:
            try validateText(code)
        }
        
        let qrCode = QRCode(
            id: UUID().uuidString,
            content: code,
            timestamp: Date()
        )
        
        do {
            try await repository.saveQRCode(qrCode)
            return qrCode
        } catch {
            throw QRCodeServiceError.processingFailed
        }
    }
    
    func validateQRCode(_ code: String) -> Bool {
        // Validación básica de formato
        guard !code.isEmpty else { return false }
        
        // Validación de longitud máxima
        guard code.count <= 2048 else { return false }
        
        // Validación de caracteres permitidos
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: ":/?=&,;@+"))
        guard code.unicodeScalars.allSatisfy(allowedCharacters.contains) else { return false }
        
        return true
    }
    
    func detectQRCodeType(_ code: String) -> QRCodeType {
        if code.hasPrefix("http") {
            return .url
        } else if code.hasPrefix("WIFI:") {
            return .wifi
        } else if code.hasPrefix("BEGIN:VCARD") {
            return .contact
        } else if code.hasPrefix("tel:") {
            return .phone
        } else if code.hasPrefix("mailto:") {
            return .email
        } else if code.hasPrefix("sms:") {
            return .sms
        } else {
            return .text
        }
    }
    
    private func validateURL(_ code: String) throws {
        guard let url = URL(string: code),
              url.scheme == "https",
              url.host != nil else {
            throw QRCodeServiceError.invalidURL
        }
    }
    
    private func validateWifiConfig(_ code: String) throws {
        let components = code.components(separatedBy: ";")
        guard components.contains(where: { $0.hasPrefix("S:") }),
              components.contains(where: { $0.hasPrefix("T:") }) else {
            throw QRCodeServiceError.invalidWifiConfig
        }
    }
    
    private func validateContact(_ code: String) throws {
        guard code.contains("BEGIN:VCARD") && code.contains("END:VCARD"),
              code.contains("VERSION:") else {
            throw QRCodeServiceError.invalidContact
        }
    }
    
    private func validatePhone(_ code: String) throws {
        let phoneNumber = code.replacingOccurrences(of: "tel:", with: "")
        let cleanNumber = phoneNumber.filter { $0.isNumber || $0 == "+" }
        guard cleanNumber.count >= 10,
              cleanNumber.hasPrefix("+") else {
            throw QRCodeServiceError.invalidPhone
        }
    }
    
    private func validateEmail(_ code: String) throws {
        let email = code.replacingOccurrences(of: "mailto:", with: "")
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            throw QRCodeServiceError.invalidEmail
        }
    }
    
    private func validateSMS(_ code: String) throws {
        let components = code.components(separatedBy: ":")
        guard components.count >= 2 else {
            throw QRCodeServiceError.invalidSMS
        }
        
        let phoneNumber = components[1].components(separatedBy: "?")[0]
        let cleanNumber = phoneNumber.filter { $0.isNumber || $0 == "+" }
        guard cleanNumber.count >= 10,
              cleanNumber.hasPrefix("+") else {
            throw QRCodeServiceError.invalidPhone
        }
    }
    
    private func validateText(_ code: String) throws {
        // Validar que no contenga caracteres peligrosos
        let dangerousCharacters = CharacterSet(charactersIn: "<>\"'&")
        guard !code.unicodeScalars.contains(where: { dangerousCharacters.contains($0) }) else {
            throw QRCodeServiceError.invalidCharacters
        }
    }
} 