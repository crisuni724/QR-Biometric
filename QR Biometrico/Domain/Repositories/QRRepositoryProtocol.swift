import Foundation

protocol QRRepositoryProtocol {
    func saveQRCode(_ code: QRCode) async throws
    func getAllQRCodes() async throws -> [QRCode]
    func deleteQRCode(_ code: QRCode) async throws
    func getQRCode(byId id: UUID) async throws -> QRCode?
} 