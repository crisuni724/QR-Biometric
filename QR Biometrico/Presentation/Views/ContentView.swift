//
//  ContentView.swift
//  QR Biometrico
//
//  Created by Cris Developer on 30/3/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var qrViewModel = QRScannerViewModel()
    @State private var showingScanner = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(qrViewModel.scannedCodes) { qrCode in
                    VStack(alignment: .leading) {
                        Text(qrCode.content)
                            .font(.headline)
                        Text(qrCode.timestamp, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            Task {
                                await qrViewModel.deleteQRCode(qrCode)
                            }
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Códigos QR")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingScanner = true
                    }) {
                        Image(systemName: "qrcode.viewfinder")
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                QRScannerContainerView()
            }
            .alert("Error", isPresented: .constant(qrViewModel.error != nil)) {
                Button("OK") {
                    qrViewModel.error = nil
                }
            } message: {
                Text(qrViewModel.error ?? "")
            }
            .task {
                await qrViewModel.loadScannedCodes()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
