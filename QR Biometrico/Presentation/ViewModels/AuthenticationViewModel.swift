import Foundation
import Combine
import LocalAuthentication

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var showPINInput = false
    @Published var error: String?
    @Published var isLoading = false
    @Published var biometricType: BiometricType = .none
    @Published var pin = ""
    @Published var isSettingUpPIN = false
    
    private let authenticationUseCase: AuthenticationUseCaseProtocol
    private let keychainService: KeychainService
    
    init(authenticationUseCase: AuthenticationUseCaseProtocol = AuthenticationUseCase(),
         keychainService: KeychainService = .shared) {
        self.authenticationUseCase = authenticationUseCase
        self.keychainService = keychainService
        self.biometricType = authenticationUseCase.biometricType
    }
    
    func authenticate() async {
        isLoading = true
        error = nil
        
        do {
            if authenticationUseCase.isBiometricAvailable() {
                isAuthenticated = try await authenticationUseCase.authenticateWithBiometrics()
            } else {
                showPINInput = true
            }
        } catch {
            self.error = error.localizedDescription
            showPINInput = true
        }
        
        isLoading = false
    }
    
    func authenticateWithPin(_ pin: String) async {
        isLoading = true
        error = nil
        
        do {
            isAuthenticated = try await authenticationUseCase.authenticateWithPin(pin)
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func verifyPIN() async {
        do {
            let storedPIN = try keychainService.getPIN()
            if pin == storedPIN {
                isAuthenticated = true
                pin = ""
            } else {
                self.error = "PIN incorrecto"
            }
        } catch KeychainError.itemNotFound {
            isSettingUpPIN = true
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func setupPIN() async {
        do {
            try keychainService.savePIN(pin)
            isAuthenticated = true
            isSettingUpPIN = false
            pin = ""
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func signOut() {
        isAuthenticated = false
        pin = ""
        showPINInput = false
    }
} 