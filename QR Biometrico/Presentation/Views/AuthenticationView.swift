import SwiftUI

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var pin = ""
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.isAuthenticated {
                ContentView()
            } else {
                authenticationContent
            }
        }
        .padding()
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            Text(viewModel.error ?? "")
        }
    }
    
    private var authenticationContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("QR Biometrico")
                .font(.title)
                .bold()
            
            if viewModel.showPinInput {
                SecureField("PIN", text: $pin)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
                Button("Autenticar con PIN") {
                    Task {
                        await viewModel.authenticateWithPin(pin)
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Autenticar con Face ID/Touch ID") {
                    Task {
                        await viewModel.authenticate()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
} 