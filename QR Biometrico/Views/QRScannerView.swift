import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @StateObject private var viewModel: QRScannerViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: QRScannerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            QRScannerPreview()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                switch viewModel.state {
                case .idle:
                    startButton
                case .scanning:
                    scanningOverlay
                case .processing:
                    processingOverlay
                case .success:
                    successOverlay
                case .error(let message):
                    errorOverlay(message)
                }
                
                Spacer()
            }
        }
        .task {
            await viewModel.startScanning()
        }
        .onDisappear {
            Task {
                await viewModel.stopScanning()
            }
        }
    }
    
    private var startButton: some View {
        Button(action: {
            Task {
                await viewModel.startScanning()
            }
        }) {
            Text("Iniciar Escaneo")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
    
    private var scanningOverlay: some View {
        VStack {
            Text("Escaneando...")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
            
            Button(action: {
                Task {
                    await viewModel.stopScanning()
                }
            }) {
                Text("Detener")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding(.top)
        }
    }
    
    private var processingOverlay: some View {
        ProgressView("Procesando...")
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(10)
    }
    
    private var successOverlay: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text("¡Código QR escaneado!")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
            
            Button(action: {
                viewModel.reset()
            }) {
                Text("Escanear otro")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.top)
        }
    }
    
    private func errorOverlay(_ message: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text(message)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
            
            Button(action: {
                viewModel.reset()
            }) {
                Text("Reintentar")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.top)
        }
    }
}

struct QRScannerPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
} 