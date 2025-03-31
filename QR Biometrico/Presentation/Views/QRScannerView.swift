import SwiftUI
import AVFoundation

struct QRScannerView: UIViewRepresentable {
    @ObservedObject var viewModel: QRScannerViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        if let session = try? viewModel.getScannerService().setupCaptureSession() {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = view.frame
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        Task {
            await viewModel.startScanning()
        }
    }
}

struct QRScannerContainerView: View {
    @StateObject private var viewModel = QRScannerViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            QRScannerView(viewModel: viewModel)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Coloca el código QR dentro del marco")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom, 50)
            }
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            Text(viewModel.error ?? "")
        }
        .onDisappear {
            viewModel.stopScanning()
        }
    }
}

struct QRScannerPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
} 

