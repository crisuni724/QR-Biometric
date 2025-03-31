import Foundation
import LocalAuthentication

protocol AuthenticationUseCaseProtocol {
    func authenticateWithBiometrics() async throws -> Bool
    func authenticateWithPin(_ pin: String) async throws -> Bool
    func isBiometricAvailable() -> Bool
}

class AuthenticationUseCase: AuthenticationUseCaseProtocol {
    private let context = LAContext()
    
    func isBiometricAvailable() -> Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticateWithBiometrics() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: "Autenticación requerida") { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    func authenticateWithPin(_ pin: String) async throws -> Bool {
        // Implementar lógica de autenticación con PIN
        // Por ahora retornamos true para pruebas
        return true
    }
} 