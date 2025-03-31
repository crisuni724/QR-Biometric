//
//  QR_BiometricoApp.swift
//  QR Biometrico
//
//  Created by Cris Developer on 30/3/25.
//

import SwiftUI
import CoreData

@main
struct QR_BiometricoApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
