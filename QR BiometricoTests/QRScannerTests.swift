import XCTest
import AVFoundation
@testable import QR_Biometrico

class MockQRScannerService: QRScannerServiceProtocol {
    var shouldSucceed: Bool
    var shouldThrowError: Bool
    var isScanning: Bool = false
    
    init(shouldSucceed: Bool = true, shouldThrowError: Bool = false) {
        self.shouldSucceed = shouldSucceed
        self.shouldThrowError = shouldThrowError
    }
    
    func setupCaptureSession() throws -> AVCaptureSession {
        if shouldThrowError {
            throw NSError(domain: "QRScanner", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error de prueba"])
        }
        return AVCaptureSession()
    }
    
    func startScanning() async throws {
        if shouldThrowError {
            throw NSError(domain: "QRScanner", code: 2, userInfo: [NSLocalizedDescriptionKey: "Error de prueba"])
        }
        isScanning = true
    }
    
    func stopScanning() async {
        isScanning = false
    }
    
    func setCompletionHandler(_ handler: @escaping (Result<String, Error>) -> Void) {
        if shouldSucceed {
            handler(.success("QR Code de prueba"))
        } else {
            handler(.failure(NSError(domain: "QRScanner", code: 3, userInfo: [NSLocalizedDescriptionKey: "Error de prueba"])))
        }
    }
}

@MainActor
final class QRScannerTests: XCTestCase {
    var sut: QRScannerViewModel!
    var mockScannerService: MockQRScannerService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockScannerService = MockQRScannerService()
        sut = QRScannerViewModel(scannerService: mockScannerService)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockScannerService = nil
        try super.tearDownWithError()
    }
    
    func testSuccessfulQRScanning() async throws {
        // Given
        mockScannerService.shouldSucceed = true
        
        // When
        await sut.startScanning()
        
        // Then
        XCTAssertTrue(sut.isScanning)
        XCTAssertNil(sut.error)
        XCTAssertEqual(sut.scannedCodes.count, 1)
        XCTAssertEqual(sut.scannedCodes.first?.content, "QR Code de prueba")
    }
    
    func testFailedQRScanning() async throws {
        // Given
        mockScannerService.shouldSucceed = false
        
        // When
        await sut.startScanning()
        
        // Then
        XCTAssertTrue(sut.isScanning)
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.scannedCodes.count, 0)
    }
    
    func testStopScanning() async throws {
        // Given
        await sut.startScanning()
        XCTAssertTrue(sut.isScanning)
        
        // When
        await sut.stopScanning()
        
        // Then
        XCTAssertFalse(sut.isScanning)
    }
    
    func testLoadScannedCodes() async throws {
        // When
        await sut.loadScannedCodes()
        
        // Then
        XCTAssertEqual(sut.scannedCodes.count, 1)
        XCTAssertEqual(sut.scannedCodes.first?.content, "Test QR Code")
    }
} 