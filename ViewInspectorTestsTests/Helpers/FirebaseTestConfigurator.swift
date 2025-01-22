//
//  FirebaseTestConfigurator.swift
//  ViewInspectorTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//

import FirebaseCore
import ViewInspectorPOC

public struct FirebaseTestConfigurator {
    public enum Environment: String {
        case dev = "GoogleService-Info"
    }
    
    public static func configureForTests() {
        // Check if Firebase is already configured
        if FirebaseApp.app() == nil {
            let bundleRemoteSpot = Bundle(for: RemoteFirebaseSpotLoader.self)
            guard let filePath = bundleRemoteSpot.path(forResource: Environment.dev.rawValue, ofType: "plist") else {
                fatalError("Could not find the Firebase configuration file: \(Environment.dev.rawValue).plist in the main bundle")
            }
            
            guard let options = FirebaseOptions(contentsOfFile: filePath) else {
                fatalError("Failed to load Firebase options from GoogleService-Info-Test.plist")
            }
            
            FirebaseApp.configure(options: options)
        }
    }
}
