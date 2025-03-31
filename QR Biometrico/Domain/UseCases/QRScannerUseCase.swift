import Foundation
import AVFoundation
import Vision

protocol QRScannerUseCaseProtocol {
    func setupCaptureSession() -> AVCaptureSession?
    func processQRCode(_ code: String) async throws
}

class QRScannerUseCase: NSObject, QRScannerUseCaseProtocol, AVCaptureMetadataOutputObjectsDelegate {
    private let qrRepository: QRCodeRepositoryProtocol
    
    init(qrRepository: QRCodeRepositoryProtocol) {
        self.qrRepository = qrRepository
        super.init()
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
        let qrCode = QRCode(content: code)
        try await qrRepository.saveQRCode(qrCode)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {
            return
        }
        
        Task {
            try? await processQRCode(stringValue)
        }
    }
} 