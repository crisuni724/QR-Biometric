import Foundation
import AVFoundation
import Combine

enum QRScannerState {
    case idle
    case scanning
    case processing
    case success
    case error(String)
}

@MainActor
class QRScannerViewModel: ObservableObject {
    @Published private(set) var state: QRScannerState = .idle
    @Published private(set) var lastScannedCode: QRCode?
    @Published private(set) var isScanning = false
    @Published private(set) var errorMessage: String?
    
    private let scannerService: QRScannerServiceProtocol
    private let qrCodeService: QRCodeServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(scannerService: QRScannerServiceProtocol,
         qrCodeService: QRCodeServiceProtocol) {
        self.scannerService = scannerService
        self.qrCodeService = qrCodeService
        
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        scannerService.scanResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] code in
                Task {
                    await self?.handleScannedCode(code)
                }
            }
            .store(in: &cancellables)
        
        scannerService.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleError(error)
            }
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: QRScannerError) {
        state = .error(error.localizedDescription)
        errorMessage = error.localizedDescription
        isScanning = false
    }
    
    func startScanning() async {
        state = .scanning
        isScanning = true
        errorMessage = nil
        
        do {
            try await scannerService.setupCaptureSession()
            try await scannerService.startScanning()
        } catch {
            handleError(error as? QRScannerError ?? .setupFailed)
        }
    }
    
    func stopScanning() async {
        state = .idle
        isScanning = false
        errorMessage = nil
        
        do {
            try await scannerService.stopScanning()
        } catch {
            handleError(error as? QRScannerError ?? .scanningFailed)
        }
    }
    
    private func handleScannedCode(_ code: String) async {
        state = .processing
        errorMessage = nil
        
        do {
            let qrCode = try await qrCodeService.processQRCode(code)
            lastScannedCode = qrCode
            
            // Notificar a través de una notificación local
            NotificationCenter.default.post(
                name: .qrCodeScanned,
                object: nil,
                userInfo: [
                    "id": qrCode.id,
                    "content": qrCode.content,
                    "timestamp": qrCode.timestamp.timeIntervalSince1970,
                    "type": detectQRCodeType(code)
                ]
            )
            
            state = .success
            isScanning = false
        } catch {
            handleError(error as? QRScannerError ?? .processingError)
        }
    }
    
    private func detectQRCodeType(_ code: String) -> String {
        if code.hasPrefix("http") {
            return "url"
        } else if code.hasPrefix("WIFI:") {
            return "wifi"
        } else if code.hasPrefix("BEGIN:VCARD") {
            return "contact"
        } else if code.hasPrefix("tel:") {
            return "phone"
        } else if code.hasPrefix("mailto:") {
            return "email"
        } else if code.hasPrefix("sms:") {
            return "sms"
        } else {
            return "text"
        }
    }
    
    func reset() {
        state = .idle
        lastScannedCode = nil
        isScanning = false
        errorMessage = nil
    }
}

// Extensión para la notificación
extension Notification.Name {
    static let qrCodeScanned = Notification.Name("qrCodeScanned")
} 