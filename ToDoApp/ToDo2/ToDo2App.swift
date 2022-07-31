//
//  ToDo2App.swift
//  ToDo2
//
//  Created by Mehmet Erdem Keskin on 12.07.2022.
//

import SwiftUI

@main
struct ToDo2App: App {
    
    let persistentContainer = CoreDataManager.shared.persistentContainer
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistentContainer.viewContext)
        }
    }
}
