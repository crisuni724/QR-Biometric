# QR Biometrico

Una aplicación iOS nativa que implementa escaneo de códigos QR con autenticación biométrica y se integra con Flutter para funcionalidades adicionales.

## Características

- Escaneo de códigos QR usando la cámara del dispositivo
- Autenticación biométrica (Face ID/Touch ID)
- Almacenamiento seguro de datos usando Keychain
- Persistencia local de códigos QR escaneados
- Integración con Flutter para funcionalidades adicionales
- Interfaz de usuario moderna y responsiva
- Soporte para modo oscuro
- Localización en español e inglés

## Requisitos

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+
- CocoaPods
- Flutter SDK 3.19.0+

## Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/crisdeveloper/qr-biometrico.git
cd qr-biometrico
```

2. Instala Flutter (si no lo tienes instalado):
```bash
brew install flutter
flutter doctor
```

3. Configura el módulo Flutter:
```bash
cd flutter_module
flutter pub get
cd ..
```

4. Instala las dependencias de iOS:
```bash
pod install
```

5. Abre el proyecto en Xcode:
```bash
open QR\ Biometrico.xcworkspace
```

## Arquitectura

### Estructura del Proyecto

```
QR Biometrico/
├── Presentation/
│   ├── Views/
│   │   ├── QRScannerView.swift      # Vista principal del escáner QR
│   │   └── AuthenticationView.swift  # Vista de autenticación
│   └── ViewModels/
│       ├── QRScannerViewModel.swift  # ViewModel del escáner
│       └── AuthenticationViewModel.swift
├── Domain/
│   ├── UseCases/
│   │   ├── QRScannerUseCase.swift   # Lógica de negocio del escáner
│   │   └── AuthenticationUseCase.swift
│   └── Models/
│       └── QRCode.swift             # Modelo de datos QR
├── Data/
│   ├── Sources/
│   │   ├── QRScannerService.swift   # Servicio de escaneo
│   │   └── BiometricAuthService.swift
│   └── Repositories/
│       └── QRCodeRepository.swift    # Persistencia de datos
└── FlutterBridge/
    └── FlutterBridge.swift          # Integración con Flutter

flutter_module/
├── lib/
│   └── main.dart                    # Aplicación Flutter
└── ios/
    └── Flutter.podspec              # Configuración de pods Flutter
```

### Integración Swift-Flutter

La aplicación utiliza una arquitectura híbrida donde Swift maneja las funcionalidades nativas (cámara, biometría) y Flutter proporciona una interfaz de usuario adicional. La comunicación entre ambas partes se realiza a través de MethodChannels.

#### Configuración del Puente Flutter

1. El `FlutterBridge.swift` maneja la comunicación:
```swift
class FlutterBridge: NSObject {
    private var flutterEngine: FlutterEngine?
    private var methodChannel: FlutterMethodChannel?
    
    func initialize() {
        flutterEngine = FlutterEngine(name: "qr_biometrico_flutter")
        methodChannel = FlutterMethodChannel(
            name: "com.qrbiometrico.app/flutter",
            binaryMessenger: flutterEngine!.binaryMessenger
        )
        methodChannel?.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
        flutterEngine?.run()
    }
}
```

2. El `AppDelegate.swift` inicializa el puente:
```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var flutterBridge: FlutterBridge?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let biometricAuthService = BiometricAuthService()
        let qrScannerService = QRScannerService()
        
        flutterBridge = FlutterBridge(
            biometricAuthService: biometricAuthService,
            qrScannerService: qrScannerService
        )
        flutterBridge?.initialize()
        
        return true
    }
}
```

#### Métodos Disponibles

El puente Flutter-Swift expone los siguientes métodos:

1. **Autenticación**:
   - `checkAuthentication`: Verifica el estado de autenticación
   - `authenticate`: Inicia el proceso de autenticación biométrica

2. **Escaneo QR**:
   - `scanQR`: Activa la cámara y escanea un código QR

#### Uso desde Flutter

```dart
class _HomePageState extends State<HomePage> {
  static const platform = MethodChannel('com.qrbiometrico.app/flutter');
  
  Future<void> _authenticate() async {
    try {
      final bool isAuthenticated = await platform.invokeMethod('authenticate');
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }
  
  Future<void> _scanQR() async {
    try {
      final String? result = await platform.invokeMethod('scanQR');
      if (result != null) {
        setState(() {
          _qrContent = result;
        });
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }
}
```

## Desarrollo

### Ejecutar la Aplicación

1. Asegúrate de que el módulo Flutter esté configurado:
```bash
cd flutter_module
flutter pub get
cd ..
```

2. Instala las dependencias de CocoaPods:
```bash
pod install
```

3. Abre el workspace en Xcode:
```bash
open QR\ Biometrico.xcworkspace
```

4. Selecciona el simulador o dispositivo y presiona Run (⌘R)

### Pruebas

Para ejecutar las pruebas unitarias:
```bash
fastlane tests
```

### Construcción

Para desarrollo:
```bash
fastlane build_dev
```

Para producción:
```bash
fastlane build_prod
```

### Despliegue

A TestFlight:
```bash
fastlane deploy_testflight
```

A App Store:
```bash
fastlane deploy_appstore
```

## Solución de Problemas

### Errores Comunes

1. **Error de Flutter no encontrado**:
```
Flutter.framework not found
```
Solución:
```bash
cd flutter_module
flutter pub get
cd ..
pod install
```

2. **Error de MethodChannel**:
```
FlutterMethodNotImplemented
```
Solución: Verifica que el nombre del canal y los métodos coincidan exactamente entre Swift y Flutter.

3. **Error de Permisos de Cámara**:
Asegúrate de tener el siguiente permiso en Info.plist:
```xml
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para escanear códigos QR</string>
```

4. **Error de Biometría**:
Asegúrate de tener el siguiente permiso en Info.plist:
```xml
<key>NSFaceIDUsageDescription</key>
<string>Necesitamos acceso a Face ID para autenticar al usuario</string>
```

## Contribuir

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## Contacto

Cristian Developer - [@crisdeveloper](https://twitter.com/crisdeveloper)

Link del Proyecto: [https://github.com/crisdeveloper/qr-biometrico](https://github.com/crisdeveloper/qr-biometrico) 