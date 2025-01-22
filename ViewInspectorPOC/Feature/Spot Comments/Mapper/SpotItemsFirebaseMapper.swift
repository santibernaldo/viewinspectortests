//
//  SpotItemsFirebaseMapper.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//


import Foundation

public final class SpotItemsFirebaseMapper {
    
    private init() {}
    
    public struct RemoteFirebaseSpotItemDTO: Decodable {
        public let id: String
        public let title: String
        public let description: String?
        public let location: String
        public let hasWifi: Bool?
        public let image: URL
        public let locationCoordinates: RemoteFirebaseRSLocation
    }
    
    public struct RemoteFirebaseRSLocation: Decodable {
        public let latitude: Double
        public let longitude: Double
        
        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
        
        public func toDictionary() -> [String: Any] {
                return ["latitude": latitude, "longitude": longitude]
        }
    }

    public static func map(_ snapshot: QuerySnapshot?) throws -> [RemoteFirebaseSpotItemDTO] {
        guard let documents = snapshot?.documents else { throw RemoteFirebaseSpotLoader.Error.emptySnapshot }
    
        let spots: [RemoteFirebaseSpotItemDTO] = try documents.compactMap { document in
            do {
                if let spotResponse = try getDTORemoteObject(dataDict: document.data) {
                    return spotResponse
                } else {
                    throw RemoteFirebaseSpotLoader.Error.invalidData
                }
            } catch {
                throw RemoteFirebaseSpotLoader.Error.invalidData
            }
        }
        
        return spots
    }
    
    public static func mapDocuments(_ documents: [QueryDocumentSnapshotProtocol]?) throws -> [RemoteFirebaseSpotItemDTO] {
        guard let documents = documents else { throw RemoteFirebaseSpotLoader.Error.emptySnapshot }
    
        let spots: [RemoteFirebaseSpotItemDTO] = try documents.compactMap { document in
            do {
                if let spotResponse = try getDTORemoteObject(dataDict: document.data) {
                    return spotResponse
                } else {
                    throw RemoteFirebaseSpotLoader.Error.invalidData
                }
            } catch {
                throw RemoteFirebaseSpotLoader.Error.invalidData
            }
        }
        
        return spots
    }
    
    private static func getDTORemoteObject(dataDict: [String: Any]) throws -> RemoteFirebaseSpotItemDTO? {
        guard let data = try? JSONSerialization.data(withJSONObject: dataDict) else { return nil }
        
        let decoder = JSONDecoder()
        var spot: RemoteFirebaseSpotItemDTO

        do {
            spot = try decoder.decode(RemoteFirebaseSpotItemDTO.self, from: data)
            return spot
        } catch {
            throw RemoteFirebaseSpotLoader.Error.invalidData
        }
    }
}

