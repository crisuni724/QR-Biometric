import UIKit
import Flutter

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var flutterBridge: FlutterBridge?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Inicializar servicios
        let biometricAuthService = BiometricAuthService()
        let qrScannerService = QRScannerService()
        
        // Inicializar el puente Flutter
        flutterBridge = FlutterBridge(
            biometricAuthService: biometricAuthService,
            qrScannerService: qrScannerService
        )
        flutterBridge?.initialize()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        flutterBridge?.cleanup()
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
} 