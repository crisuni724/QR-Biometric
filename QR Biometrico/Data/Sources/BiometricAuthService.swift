import LocalAuthentication
import Foundation

enum BiometricError: Error {
    case authenticationFailed
    case biometryNotAvailable
    case biometryNotEnrolled
    case biometryLockout
    case unknown
}

protocol BiometricAuthServiceProtocol {
    var biometricType: BiometricType { get }
    func authenticate(reason: String) async throws -> Bool
}

class BiometricAuthService: BiometricAuthServiceProtocol {
    private let context = LAContext()
    
    var biometricType: BiometricType {
        BiometricType.getType()
    }
    
    func authenticate(reason: String) async throws -> Bool {
        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
        } catch let error as LAError {
            switch error.code {
            case .authenticationFailed:
                throw BiometricError.authenticationFailed
            case .biometryNotAvailable:
                throw BiometricError.biometryNotAvailable
            case .biometryNotEnrolled:
                throw BiometricError.biometryNotEnrolled
            case .biometryLockout:
                throw BiometricError.biometryLockout
            default:
                throw BiometricError.unknown
            }
        }
    }
} 