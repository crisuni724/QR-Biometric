import SwiftUI
import Flutter

@main
struct QRBiometricoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var flutterEngine: FlutterEngine?
    var methodChannel: FlutterMethodChannel?
    
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupFlutterEngine()
        return true
    }
    
    private func setupFlutterEngine() {
        flutterEngine = FlutterEngine(name: "qr_biometrico_engine")
        
        guard let flutterEngine = flutterEngine else { return }
        
        flutterEngine.run()
        
        let controller = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        
        methodChannel = FlutterMethodChannel(
            name: "com.qrbiometrico.app/scanner",
            binaryMessenger: controller.binaryMessenger
        )
        
        methodChannel?.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startScanner":
            startScanner(result: result)
        case "stopScanner":
            stopScanner(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func startScanner(result: @escaping FlutterResult) {
        // Implementar lógica para iniciar el escáner
        result(true)
    }
    
    private func stopScanner(result: @escaping FlutterResult) {
        // Implementar lógica para detener el escáner
        result(true)
    }
}

struct ContentView: View {
    @State private var isScannerPresented = false
    
    var body: some View {
        VStack {
            Text("QR Biometrico")
                .font(.largeTitle)
                .padding()
            
            Button(action: {
                isScannerPresented = true
            }) {
                Text("Escanear QR")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .sheet(isPresented: $isScannerPresented) {
            QRScannerView(viewModel: makeQRScannerViewModel())
        }
    }
    
    private func makeQRScannerViewModel() -> QRScannerViewModel {
        let repository = QRCodeRepository()
        let scannerService = QRScannerService()
        let qrCodeService = QRCodeService(repository: repository)
        
        guard let methodChannel = (UIApplication.shared.delegate as? AppDelegate)?.methodChannel else {
            fatalError("Method channel not initialized")
        }
        
        return QRScannerViewModel(
            scannerService: scannerService,
            qrCodeService: qrCodeService,
            methodChannel: methodChannel
        )
    }
} 