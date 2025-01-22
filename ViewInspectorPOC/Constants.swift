//
//  RemoteSpotConstants.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//

import FirebaseFirestore

public struct Constants {
    public struct CollectionFirebase {
        public static let spots = Firestore.firestore().collection("spots")
        public static let users = Firestore.firestore().collection("users")
        public static let comments = "comments"
    }
}

