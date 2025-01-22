//
//  RemoteFirebaseSpotLoader.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//

import Foundation

public class RemoteFirebaseSpotLoader: SpotsLoader {
    
    private let client: FirebaseCollectionProtocol
    
    public init(client: FirebaseCollectionProtocol) {
        self.client = client
    }
    
    typealias Result = SpotsLoader.Result
    
    // STAR: Domain Error level
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case emptySnapshot
    }
    
    // TODO: Maybe not getting always .invalidData, this is a code smell
    public func load() async throws -> SpotsLoader.Result {
        do {
            let snapshot = try await client.getDocuments()
            return RemoteFirebaseSpotLoader.map(snapshot)
        } catch {
            throw Error.invalidData
        }
    }
    
    private static func map(_ snapshot: QuerySnapshot) -> SpotsLoader.Result {
        do {
            let spots = try SpotItemsFirebaseMapper.map(snapshot).toModelsSpotItem()
            return .success(spots)
        } catch {
            return .failure(error)
        }
    }
}

extension Array where Element == SpotItemsFirebaseMapper.RemoteFirebaseSpotItemDTO {
    public func toModelsSpotItem() -> [SpotItem] {
        map { SpotItem(id: UUID(uuidString: $0.id) ?? UUID(), title: $0.title, description: $0.description, location: $0.location, hasWifi: $0.hasWifi, imageURL: $0.image, locationCoordinates: RSLocation(latitude: Double($0.locationCoordinates.latitude), longitude: Double($0.locationCoordinates.longitude)), idFirebaseDocument: $0.id) }
    }
}
