//
//  SpotItem.swift
//  ViewInspectorTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 16/1/25.
//

import Foundation

public struct SpotItem: Identifiable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let location: String
 
    init(id: UUID, title: String, description: String?, location: String) {
        self.id = id
        self.title = title
        self.description = description
        self.location = location
    }
}

