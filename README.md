# QR Biometrico

Aplicación iOS para escaneo de códigos QR con autenticación biométrica.

## Características

- Escaneo de códigos QR usando la cámara del dispositivo
- Autenticación biométrica (Face ID / Touch ID)
- Fallback a PIN cuando falla la autenticación biométrica
- Almacenamiento seguro de datos usando Keychain
- Interfaz de usuario moderna con SwiftUI
- Arquitectura limpia y modular
- Pruebas unitarias y de UI
- Automatización con Fastlane

## Requisitos

- iOS 15.0+
- Xcode 15.0+
- Swift 5.0+
- CocoaPods
- Fastlane
- Homebrew (para SwiftLint)

## Instalación

1. Clonar el repositorio:
```bash
git clone https://github.com/tu-usuario/qr-biometrico.git
cd qr-biometrico
```

2. Instalar dependencias:
```bash
# Instalar dependencias de Ruby y CocoaPods
bundle install

# Instalar dependencias de CocoaPods
pod install

# O usar Fastlane para instalar todo automáticamente
bundle exec fastlane setup
```

3. Abrir el proyecto:
```bash
open QR\ Biometrico.xcworkspace
```

## Estructura del Proyecto

```
QR Biometrico/
├── Domain/
│   ├── Entities/
│   └── UseCases/
├── Data/
│   ├── Sources/
│   └── Repositories/
├── Presentation/
│   ├── Views/
│   └── ViewModels/
├── Tests/
│   ├── QR BiometricoTests/
│   └── QR BiometricoUITests/
└── Resources/
```

## Uso

1. Al iniciar la aplicación, se solicitará autenticación biométrica
2. Si la autenticación biométrica falla, se puede usar PIN como respaldo
3. Una vez autenticado, se puede acceder al escáner de QR
4. Los códigos QR escaneados se almacenan localmente

## Automatización

El proyecto usa Fastlane para automatizar tareas comunes:

```bash
# Instalar todas las dependencias
bundle exec fastlane setup

# Ejecutar pruebas
bundle exec fastlane tests

# Construir la aplicación
bundle exec fastlane build

# Desplegar a TestFlight
bundle exec fastlane beta

# Desplegar a App Store
bundle exec fastlane release

# Ejecutar CI completo
bundle exec fastlane ci
```

## Contribuir

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles. 