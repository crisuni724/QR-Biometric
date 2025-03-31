import Foundation
import AVFoundation
import Combine

@MainActor
class QRScannerViewModel: ObservableObject {
    @Published var scannedCodes: [QRCode] = []
    @Published var error: Error?
    @Published var isScanning = false
    
    private let scannerService: QRScannerServiceProtocol
    private let repository: QRCodeRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(scannerService: QRScannerServiceProtocol, repository: QRCodeRepositoryProtocol) {
        self.scannerService = scannerService
        self.repository = repository
        super.init()
        setupBindings()
    }
    
    private func setupBindings() {
        scannerService.scanResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.handleScanResult(result)
            }
            .store(in: &cancellables)
    }
    
    // Método público para obtener el servicio del escáner
    func getScannerService() -> QRScannerServiceProtocol {
        return scannerService
    }
    
    func startScanning() async {
        do {
            try await scannerService.setupCaptureSession()
            try await scannerService.startScanning()
            isScanning = true
        } catch {
            self.error = error
            isScanning = false
        }
    }
    
    func stopScanning() async {
        do {
            try await scannerService.stopScanning()
            isScanning = false
        } catch {
            self.error = error
        }
    }
    
    func loadScannedCodes() async {
        do {
            scannedCodes = try await repository.getScannedCodes()
        } catch {
            self.error = error
        }
    }
    
    private func handleScanResult(_ result: String) {
        Task {
            do {
                let qrCode = QRCode(content: result)
                try await repository.saveQRCode(qrCode)
                await loadScannedCodes()
            } catch {
                self.error = error
            }
        }
    }
    
    func deleteQRCode(_ code: QRCode) async {
        do {
            try await repository.deleteQRCode(code)
            await loadScannedCodes()
        } catch {
            self.error = error
        }
    }
} 