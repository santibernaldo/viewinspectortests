//
//  AuthFirebaseSpy.swift
//  RemoteSpot
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 19/1/25.
//

import FirebaseAuth
import ViewInspectorPOC

public protocol AuthFirebaseProtocol {
    var currentUserFirebase: FirebaseAuth.User? { get }
    func signOutFirebase() throws
}

class AuthFirebaseSpy: AuthFirebaseProtocol {
    var receivedMessages: [ReceivedMessage] = []
    
    enum ReceivedMessage: Equatable {
        case signOut
    }
    
    private var signOutResult: Result<(), Error> = .failure(anyNSError())
    
    var currentUserFirebase: FirebaseAuth.User? {
        return nil
    }
    
    func completeSignOut(with error: Error, at index: Int = 0) {
        signOutResult = .failure(error)
    }
    
    func completeSignOut(with result: (), at index: Int = 0) {
        signOutResult = .success(())
    }
    
    func signOutFirebase() throws {
        receivedMessages.append(.signOut)
        return try signOutResult.get()
    }
}
