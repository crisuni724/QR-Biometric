import XCTest
@testable import QR_Biometrico

class MockBiometricAuthService: AuthenticationUseCaseProtocol {
    var biometricType: BiometricType
    var shouldSucceed: Bool
    var shouldThrowError: Bool
    
    init(biometricType: BiometricType = .faceID,
         shouldSucceed: Bool = true,
         shouldThrowError: Bool = false) {
        self.biometricType = biometricType
        self.shouldSucceed = shouldSucceed
        self.shouldThrowError = shouldThrowError
    }
    
    func authenticateWithBiometrics() async throws -> Bool {
        if shouldThrowError {
            throw BiometricError.authenticationFailed
        }
        return shouldSucceed
    }
    
    func authenticateWithPin(_ pin: String) async throws -> Bool {
        if shouldThrowError {
            throw BiometricError.authenticationFailed
        }
        return shouldSucceed
    }
    
    func isBiometricAvailable() -> Bool {
        return true
    }
}

class MockKeychainService: KeychainService {
    var storedPIN: String?
    var shouldThrowError: Bool
    
    init(storedPIN: String? = nil, shouldThrowError: Bool = false) {
        self.storedPIN = storedPIN
        self.shouldThrowError = shouldThrowError
        super.init()
    }
    
    override func getPIN() throws -> String {
        if shouldThrowError {
            throw KeychainError.itemNotFound
        }
        guard let pin = storedPIN else {
            throw KeychainError.itemNotFound
        }
        return pin
    }
    
    override func savePIN(_ pin: String) throws {
        if shouldThrowError {
            throw KeychainError.unknown(-1)
        }
        storedPIN = pin
    }
}

@MainActor
final class AuthenticationTests: XCTestCase {
    var sut: AuthenticationViewModel!
    var mockAuthService: MockBiometricAuthService!
    var mockKeychainService: MockKeychainService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockAuthService = MockBiometricAuthService()
        mockKeychainService = MockKeychainService()
        sut = AuthenticationViewModel(authenticationUseCase: mockAuthService,
                                   keychainService: mockKeychainService)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockAuthService = nil
        mockKeychainService = nil
        try super.tearDownWithError()
    }
    
    func testSuccessfulBiometricAuthentication() async throws {
        // Given
        mockAuthService.shouldSucceed = true
        
        // When
        await sut.authenticate()
        
        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.showPINInput)
    }
    
    func testFailedBiometricAuthenticationShowsPINInput() async throws {
        // Given
        mockAuthService.shouldThrowError = true
        
        // When
        await sut.authenticate()
        
        // Then
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertTrue(sut.showPINInput)
    }
    
    func testSuccessfulPINVerification() async throws {
        // Given
        mockKeychainService.storedPIN = "1234"
        sut.pin = "1234"
        
        // When
        await sut.verifyPIN()
        
        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.showPINInput)
    }
    
    func testFailedPINVerification() async throws {
        // Given
        mockKeychainService.storedPIN = "1234"
        sut.pin = "5678"
        
        // When
        await sut.verifyPIN()
        
        // Then
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertEqual(sut.error, "PIN incorrecto")
    }
    
    func testSetupNewPIN() async throws {
        // Given
        sut.pin = "1234"
        
        // When
        await sut.setupPIN()
        
        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.isSettingUpPIN)
        XCTAssertEqual(mockKeychainService.storedPIN, "1234")
    }
} 