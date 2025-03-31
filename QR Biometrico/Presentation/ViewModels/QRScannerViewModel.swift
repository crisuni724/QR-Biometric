import Foundation
import AVFoundation
import Flutter
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
    
    private let scannerService: QRScannerServiceProtocol
    private let qrCodeService: QRCodeServiceProtocol
    private let methodChannel: FlutterMethodChannel
    private var cancellables = Set<AnyCancellable>()
    
    init(scannerService: QRScannerServiceProtocol,
         qrCodeService: QRCodeServiceProtocol,
         methodChannel: FlutterMethodChannel) {
        self.scannerService = scannerService
        self.qrCodeService = qrCodeService
        self.methodChannel = methodChannel
        
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
                self?.state = .error(error.localizedDescription)
            }
            .store(in: &cancellables)
    }
    
    func startScanning() async {
        state = .scanning
        do {
            try await scannerService.setupCaptureSession()
            try await scannerService.startScanning()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func stopScanning() async {
        state = .idle
        do {
            try await scannerService.stopScanning()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    private func handleScannedCode(_ code: String) async {
        state = .processing
        
        do {
            let qrCode = try await qrCodeService.processQRCode(code)
            lastScannedCode = qrCode
            
            // Notificar a Flutter
            let result = ["id": qrCode.id,
                         "content": qrCode.content,
                         "timestamp": qrCode.timestamp.timeIntervalSince1970] as [String : Any]
            try await methodChannel.invokeMethod("onQRCodeScanned", arguments: result)
            
            state = .success
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func reset() {
        state = .idle
        lastScannedCode = nil
    }
} 