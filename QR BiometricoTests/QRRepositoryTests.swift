import XCTest
import CoreData
@testable import QR_Biometrico

class QRRepositoryTests: XCTestCase {
    var repository: CoreDataQRRepository!
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager(inMemory: true)
        repository = CoreDataQRRepository(coreDataManager: coreDataManager)
    }
    
    override func tearDown() {
        repository = nil
        coreDataManager = nil
        super.tearDown()
    }
    
    func testSaveAndRetrieveQRCode() async throws {
        // Given
        let qrCode = QRCode(content: "Test QR Code")
        
        // When
        try await repository.saveQRCode(qrCode)
        let retrievedCodes = try await repository.getAllQRCodes()
        
        // Then
        XCTAssertEqual(retrievedCodes.count, 1)
        XCTAssertEqual(retrievedCodes.first?.content, qrCode.content)
    }
    
    func testDeleteQRCode() async throws {
        // Given
        let qrCode = QRCode(content: "Test QR Code")
        try await repository.saveQRCode(qrCode)
        
        // When
        try await repository.deleteQRCode(qrCode)
        let retrievedCodes = try await repository.getAllQRCodes()
        
        // Then
        XCTAssertEqual(retrievedCodes.count, 0)
    }
    
    func testGetQRCodeById() async throws {
        // Given
        let qrCode = QRCode(content: "Test QR Code")
        try await repository.saveQRCode(qrCode)
        
        // When
        let retrievedCode = try await repository.getQRCode(byId: qrCode.id)
        
        // Then
        XCTAssertNotNil(retrievedCode)
        XCTAssertEqual(retrievedCode?.content, qrCode.content)
    }
} 