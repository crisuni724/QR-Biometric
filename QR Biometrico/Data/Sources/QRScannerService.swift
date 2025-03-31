import AVFoundation
import Foundation
import Combine

protocol QRScannerServiceProtocol {
    func setupCaptureSession() throws -> AVCaptureSession
    func startScanning() async throws
    func stopScanning() async
    func setCompletionHandler(_ handler: @escaping (Result<String, Error>) -> Void)
    var isScanning: Bool { get }
}

class QRScannerService: NSObject, QRScannerServiceProtocol {
    private var captureSession: AVCaptureSession?
    private var completionHandler: ((Result<String, Error>) -> Void)?
    private var processingQueue = DispatchQueue(label: "com.biometricapp.qrscanner.processing", qos: .userInitiated)
    private var isProcessing = false
    
    var isScanning: Bool {
        captureSession?.isRunning ?? false
    }
    
    func setupCaptureSession() throws -> AVCaptureSession {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            throw NSError(domain: "QRScanner", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se encontró dispositivo de cámara"])
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            throw NSError(domain: "QRScanner", code: 2, userInfo: [NSLocalizedDescriptionKey: "No se pudo inicializar la cámara"])
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            throw NSError(domain: "QRScanner", code: 3, userInfo: [NSLocalizedDescriptionKey: "No se pudo agregar la entrada de video"])
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: processingQueue)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            throw NSError(domain: "QRScanner", code: 4, userInfo: [NSLocalizedDescriptionKey: "No se pudo agregar la salida de metadatos"])
        }
        
        self.captureSession = session
        return session
    }
    
    func startScanning() async throws {
        guard let session = captureSession else {
            throw NSError(domain: "QRScanner", code: 5, userInfo: [NSLocalizedDescriptionKey: "Sesión no inicializada"])
        }
        
        if !session.isRunning {
            session.startRunning()
        }
    }
    
    func stopScanning() async {
        captureSession?.stopRunning()
        isProcessing = false
    }
    
    func setCompletionHandler(_ handler: @escaping (Result<String, Error>) -> Void) {
        self.completionHandler = handler
    }
}

extension QRScannerService: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Evitar procesamiento múltiple simultáneo
        guard !isProcessing else { return }
        isProcessing = true
        
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            
            // Procesar en el hilo principal
            DispatchQueue.main.async { [weak self] in
                self?.completionHandler?(.success(stringValue))
                self?.isProcessing = false
            }
        } else {
            isProcessing = false
        }
    }
} 