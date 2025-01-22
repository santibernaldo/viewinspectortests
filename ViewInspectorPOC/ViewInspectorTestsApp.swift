//
//  ViewInspectorTestsApp.swift
//  ViewInspectorTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 16/1/25.
//

import SwiftUI
import FirebaseCore

@main
struct ViewInspectorTestsApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
