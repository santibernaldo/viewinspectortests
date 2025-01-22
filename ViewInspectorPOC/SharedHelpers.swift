//
//  SharedHelpers.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//

import Foundation

func uniqueItem() -> SpotItem {
    return SpotItem(id: UUID(), title: "any title", description: "any description", location: "any location", hasWifi: false, imageURL: anyURL(), locationCoordinates: RSLocation(latitude: 36.0131, longitude: -5.6053), idFirebaseDocument: "234234234")
}

private func anyURL() -> URL {
    return URL(string: "https://static.costadelsolmalaga.org/visita/subidas/imagenes/2/6/arc_19362_g.png")!
}
