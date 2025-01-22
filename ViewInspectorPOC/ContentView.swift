//
//  ContentView.swift
//  ViewInspectorTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 16/1/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    
    private let loader = RemoteFirebaseSpotLoader(client: Constants.CollectionFirebase.spots)
    
    var body: some View {
        SpotsUIComposer.compose(loader: loader).view
    }
}

#Preview {
    ContentView()
}

