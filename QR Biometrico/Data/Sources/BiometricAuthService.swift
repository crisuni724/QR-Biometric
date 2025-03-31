import LocalAuthentication
import Foundation

enum BiometricType {
    case none
    case touchID
    case faceID
}

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