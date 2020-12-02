//
//  StorigeApp.swift
//  Storige
//
//  Created by Максим Сателайт on 02.12.2020.
//

import SwiftUI

@main
struct StorigeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
