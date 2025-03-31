import Foundation
import AVFoundation
import Combine

@MainActor
class QRScannerViewModel: ObservableObject {
    @Published var scannedCodes: [QRCode] = []
    @Published var error: String?
    @Published var isScanning = false
    
    private let scannerService: QRScannerServiceProtocol
    private let repository: QRCodeRepositoryProtocol
    
    init(scannerService: QRScannerServiceProtocol = QRScannerService(),
         repository: QRCodeRepositoryProtocol = QRCodeRepository()) {
        self.scannerService = scannerService
        self.repository = repository
    }
    
    // Método público para obtener el servicio del escáner
    func getScannerService() -> QRScannerServiceProtocol {
        return scannerService
    }
    
    func startScanning() async {
        do {
            let session = try scannerService.setupCaptureSession()
            scannerService.setCompletionHandler { [weak self] result in
                Task {
                    await self?.handleScanResult(result)
                }
            }
            try await scannerService.startScanning()
            isScanning = true
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func stopScanning() async {
        await scannerService.stopScanning()
        isScanning = false
    }
    
    func loadScannedCodes() async {
        do {
            scannedCodes = try await repository.getAllQRCodes()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func handleScanResult(_ result: Result<String, Error>) async {
        switch result {
        case .success(let content):
            let qrCode = QRCode(content: content)
            do {
                try await repository.saveQRCode(qrCode)
                await loadScannedCodes()
            } catch {
                self.error = error.localizedDescription
            }
        case .failure(let error):
            self.error = error.localizedDescription
        }
    }
    
    func deleteQRCode(_ qrCode: QRCode) async {
        do {
            try await repository.deleteQRCode(qrCode)
            await loadScannedCodes()
        } catch {
            self.error = error.localizedDescription
        }
    }
} 