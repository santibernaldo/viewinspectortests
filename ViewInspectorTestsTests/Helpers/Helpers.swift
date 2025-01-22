//
//  Helpers.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//

import ViewInspectorPOC
import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func uniqueItem() -> SpotItem {
    return SpotItem(id: UUID(), title: "any title", description: "any description", location: "any location", hasWifi: false, imageURL: anyURL(), locationCoordinates: RSLocation(latitude: 36.0131, longitude: -5.6053), idFirebaseDocument: "234234234")
}
