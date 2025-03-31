import AVFoundation
import Foundation
import Combine

enum QRScannerError: LocalizedError {
    case setupFailed
    case notAuthorized
    case scanningFailed
    case invalidInput
    case processingError
    
    var errorDescription: String? {
        switch self {
        case .setupFailed:
            return "No se pudo configurar el escáner"
        case .notAuthorized:
            return "No hay acceso a la cámara"
        case .scanningFailed:
            return "Error al escanear el código QR"
        case .invalidInput:
            return "El código QR no es válido"
        case .processingError:
            return "Error al procesar el código QR"
        }
    }
}

protocol QRScannerServiceProtocol {
    var scanResultPublisher: AnyPublisher<String, Never> { get }
    var errorPublisher: AnyPublisher<QRScannerError, Never> { get }
    func setupCaptureSession() async throws
    func startScanning() async throws
    func stopScanning() async throws
}

class QRScannerService: NSObject, QRScannerServiceProtocol, AVCaptureMetadataOutputObjectsDelegate {
    private let scanResultSubject = PassthroughSubject<String, Never>()
    private let errorSubject = PassthroughSubject<QRScannerError, Never>()
    
    var scanResultPublisher: AnyPublisher<String, Never> {
        scanResultSubject.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<QRScannerError, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    private var captureSession: AVCaptureSession?
    private var isProcessing = false
    
    var isScanning: Bool {
        captureSession?.isRunning ?? false
    }
    
    func setupCaptureSession() async throws {
        // Verificar permisos de cámara
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            guard await AVCaptureDevice.requestAccess(for: .video) else {
                throw QRScannerError.notAuthorized
            }
        case .denied, .restricted:
            throw QRScannerError.notAuthorized
        @unknown default:
            throw QRScannerError.setupFailed
        }
        
        let session = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            throw QRScannerError.setupFailed
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            throw QRScannerError.setupFailed
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            throw QRScannerError.setupFailed
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            throw QRScannerError.setupFailed
        }
        
        captureSession = session
    }
    
    func startScanning() async throws {
        guard let session = captureSession else {
            throw QRScannerError.setupFailed
        }
        
        guard !session.isRunning else { return }
        
        do {
            try await session.startRunning()
        } catch {
            throw QRScannerError.scanningFailed
        }
    }
    
    func stopScanning() async throws {
        guard let session = captureSession else {
            throw QRScannerError.setupFailed
        }
        
        guard session.isRunning else { return }
        
        session.stopRunning()
        isProcessing = false
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !isProcessing,
              let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {
            return
        }
        
        isProcessing = true
        scanResultSubject.send(stringValue)
    }
} 