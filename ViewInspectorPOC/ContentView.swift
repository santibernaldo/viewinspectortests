//
//  ContentView.swift
//  ViewInspectorTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 16/1/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    
    let spot: SpotItem = uniqueItem()
    
    public var collectionFireBaseForSpotComments: FirebaseCollectionAddDocumentProtocol {
        Constants.CollectionFirebase.spots.document(spot.idFirebaseDocument).collection(Constants.CollectionFirebase.comments)
    }
  
    var body: some View {
        SpotCommentsUIComposer.compose(spot: spot, authManager: AuthManager(authService: Auth.auth()),
                                       commentsLoader: FirebaseRemoteAddCommentsLoader(collection: collectionFireBaseForSpotComments)).view
    }
}

#Preview {
    ContentView()
}

