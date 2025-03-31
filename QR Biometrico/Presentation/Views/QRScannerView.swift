import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @StateObject private var viewModel: QRScannerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    @State private var showScanner = false
    
    init(viewModel: QRScannerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            // Fondo oscuro
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Vista del escáner
            if showScanner {
                ScannerPreviewView(session: viewModel.scannerService.captureSession)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        // Marco de escaneo
                        ScannerOverlayView(isAnimating: $isAnimating)
                    )
            }
            
            // Controles
            VStack {
                // Barra superior
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Text("Escáner QR")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Espaciador para mantener el título centrado
                    Color.clear
                        .frame(width: 44)
                }
                .background(Color.black.opacity(0.5))
                
                Spacer()
                
                // Lista de códigos escaneados
                if !viewModel.scannedCodes.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Códigos escaneados")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.scannedCodes) { code in
                                    ScannedCodeCard(code: code) {
                                        Task {
                                            await viewModel.deleteQRCode(code)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .background(Color.black.opacity(0.5))
                }
            }
        }
        .onAppear {
            // Iniciar animación
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            
            // Iniciar escáner con un pequeño retraso para la animación
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showScanner = true
                Task {
                    await viewModel.startScanning()
                }
            }
        }
        .onDisappear {
            Task {
                await viewModel.stopScanning()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
}

struct ScannerPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct ScannerOverlayView: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) * 0.7
            
            ZStack {
                // Marco exterior
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: size, height: size)
                
                // Esquinas animadas
                ForEach(0..<4) { corner in
                    ScannerCorner(corner: corner)
                        .stroke(Color.green, lineWidth: 3)
                        .frame(width: size, height: size)
                        .rotationEffect(.degrees(Double(corner) * 90))
                        .opacity(isAnimating ? 1 : 0.5)
                }
                
                // Líneas de guía
                VStack(spacing: 0) {
                    ForEach(0..<3) { _ in
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                    }
                }
                .frame(width: size, height: size)
                
                HStack(spacing: 0) {
                    ForEach(0..<3) { _ in
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 1)
                    }
                }
                .frame(width: size, height: size)
            }
        }
    }
}

struct ScannerCorner: Shape {
    let corner: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let length: CGFloat = 30
        
        switch corner {
        case 0: // Esquina superior izquierda
            path.move(to: CGPoint(x: 0, y: length))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: length, y: 0))
        case 1: // Esquina superior derecha
            path.move(to: CGPoint(x: rect.width - length, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: length))
        case 2: // Esquina inferior derecha
            path.move(to: CGPoint(x: rect.width, y: rect.height - length))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width - length, y: rect.height))
        case 3: // Esquina inferior izquierda
            path.move(to: CGPoint(x: length, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height - length))
        default:
            break
        }
        
        return path
    }
}

struct ScannedCodeCard: View {
    let code: QRCode
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(code.content)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            Text(code.timestamp.formatted())
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
        .frame(width: 200)
    }
}

#Preview {
    QRScannerView(viewModel: QRScannerViewModel(
        scannerService: QRScannerService(),
        repository: QRCodeRepository()
    ))
} 

