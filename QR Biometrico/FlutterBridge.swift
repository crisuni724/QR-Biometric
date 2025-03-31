import Flutter
import UIKit

class FlutterBridge: NSObject {
    private var flutterEngine: FlutterEngine?
    private var methodChannel: FlutterMethodChannel?
    private var biometricAuthService: BiometricAuthService
    private var qrScannerService: QRScannerService
    
    init(biometricAuthService: BiometricAuthService, qrScannerService: QRScannerService) {
        self.biometricAuthService = biometricAuthService
        self.qrScannerService = qrScannerService
        super.init()
    }
    
    func initialize() {
        // Inicializar el motor Flutter
        flutterEngine = FlutterEngine(name: "qr_biometrico_flutter")
        
        // Configurar el canal de métodos
        methodChannel = FlutterMethodChannel(
            name: "com.qrbiometrico.app/flutter",
            binaryMessenger: flutterEngine!.binaryMessenger
        )
        
        // Configurar el manejador de métodos
        methodChannel?.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
        
        // Iniciar el motor Flutter
        flutterEngine?.run()
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "checkAuthentication":
            Task {
                do {
                    let isAuthenticated = try await biometricAuthService.checkAuthentication()
                    DispatchQueue.main.async {
                        result(isAuthenticated)
                    }
                } catch {
                    DispatchQueue.main.async {
                        result(FlutterError(
                            code: "AUTH_ERROR",
                            message: error.localizedDescription,
                            details: nil
                        ))
                    }
                }
            }
            
        case "authenticate":
            Task {
                do {
                    let isAuthenticated = try await biometricAuthService.authenticate()
                    DispatchQueue.main.async {
                        result(isAuthenticated)
                    }
                } catch {
                    DispatchQueue.main.async {
                        result(FlutterError(
                            code: "AUTH_ERROR",
                            message: error.localizedDescription,
                            details: nil
                        ))
                    }
                }
            }
            
        case "scanQR":
            Task {
                do {
                    let qrContent = try await qrScannerService.scanQRCode()
                    DispatchQueue.main.async {
                        result(qrContent)
                    }
                } catch {
                    DispatchQueue.main.async {
                        result(FlutterError(
                            code: "SCAN_ERROR",
                            message: error.localizedDescription,
                            details: nil
                        ))
                    }
                }
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func cleanup() {
        methodChannel?.setMethodCallHandler(nil)
        flutterEngine?.stop()
    }
} 