import Foundation
import LocalAuthentication

protocol AuthenticationUseCaseProtocol {
    var biometricType: BiometricType { get }
    func authenticateWithBiometrics() async throws -> Bool
    func authenticateWithPin(_ pin: String) async throws -> Bool
    func isBiometricAvailable() -> Bool
}

class AuthenticationUseCase: AuthenticationUseCaseProtocol {
    private let context = LAContext()
    
    var biometricType: BiometricType {
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        default:
            return .none
        }
    }
    
    func authenticateWithBiometrics() async throws -> Bool {
        let reason = "Autenticación biométrica"
        return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
    }
    
    func authenticateWithPin(_ pin: String) async throws -> Bool {
        let reason = "Autenticación con PIN"
        return try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
    }
    
    func isBiometricAvailable() -> Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
} 