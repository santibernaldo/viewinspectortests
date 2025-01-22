//
//  RSLocation.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//


import CoreLocation

public struct RSLocation: Equatable, Hashable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
     /// Calculates the distance from the current RSLocation to a given center point.
    /// - Parameters:
    ///   - centerLatitude: The latitude of the center point.
    ///   - centerLongitude: The longitude of the center point.
    /// - Returns: A string representing the distance in "meters" or "kilometers".
    public func distanceFormatted(from centerLatitude: Double, centerLongitude: Double) -> String {
        let currentLocation = CLLocation(latitude: latitude, longitude: longitude)
        let centerLocation = CLLocation(latitude: centerLatitude, longitude: centerLongitude)
        
        let distanceInMeters = currentLocation.distance(from: centerLocation) // Distance in meters
        
        if distanceInMeters < 1000 {
            return "\(Int(distanceInMeters)) meters"
        } else {
            let distanceInKilometers = distanceInMeters / 1000
            return String(format: "%.1f kilometers", distanceInKilometers)
        }
    }
}
 
