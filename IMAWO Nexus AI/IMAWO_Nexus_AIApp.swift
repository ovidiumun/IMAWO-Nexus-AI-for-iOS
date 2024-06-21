//
//  IMAWO_Nexus_AIApp.swift
//  IMAWO Nexus AI
//
//  Created by Ovidiu Muntean on 04.10.2023.
//

import SwiftUI
import TipKit

@main
struct IMAWO_Nexus_AIApp: App {
    @StateObject private var persistenceController = PersistenceController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .task {
                        try? Tips.resetDatastore()
                        
                        try? Tips.configure([
                            .displayFrequency(.immediate),
                            .datastoreLocation(.applicationDefault)
                        ])
                    }
        }
    }
}
