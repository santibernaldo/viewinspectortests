//
//  SpotItem.swift
//  ViewInspectorTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 16/1/25.
//

import Foundation

public struct SpotItem: Equatable, Identifiable, Hashable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let location: String
    public let hasWifi: Bool?
    public let imageURL: URL
    public let locationCoordinates: RSLocation
    public let idFirebaseDocument: String
    
    public init(id: UUID, title: String, description: String?, location: String, hasWifi: Bool?, imageURL: URL, locationCoordinates: RSLocation, idFirebaseDocument: String) {
        self.id = id
        self.title = title
        self.description = description
        self.location = location
        self.hasWifi = hasWifi
        self.imageURL = imageURL
        self.locationCoordinates = locationCoordinates
        self.idFirebaseDocument = idFirebaseDocument
    }
    
    public static func == (lhs: SpotItem, rhs: SpotItem) -> Bool {
        return lhs.id == rhs.id
    }
}


