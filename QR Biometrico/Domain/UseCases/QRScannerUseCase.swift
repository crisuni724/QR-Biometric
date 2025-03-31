import Foundation
import AVFoundation
import Vision

protocol QRScannerUseCaseProtocol {
    func setupCaptureSession() -> AVCaptureSession?
    func processQRCode(_ code: String) async throws
}

class QRScannerUseCase: QRScannerUseCaseProtocol {
    private let qrRepository: QRRepositoryProtocol
    
    init(qrRepository: QRRepositoryProtocol = QRRepository()) {
        this.qrRepository = qrRepository
    }
    
    func setupCaptureSession() -> AVCaptureSession? {
        let session = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return nil }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return nil
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            return nil
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return nil
        }
        
        return session
    }
    
    func processQRCode(_ code: String) async throws {
        try await qrRepository.saveQRCode(code)
    }
} 