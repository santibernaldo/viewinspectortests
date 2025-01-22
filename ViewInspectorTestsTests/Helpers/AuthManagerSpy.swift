//
//  AuthManagerSpy.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//

import ViewInspectorPOC
import FirebaseAuth

class AuthManagerSpy: AuthManager {
    var receivedMessages: [ReceivedMessage] = []
    
    private var resultIsBiometryEnabledResult: Result<Bool, Error> = .failure(AuthManager.Error.credentialsNotFound)
    private var resultIsBiometryForFirebaseGuaranteed: Result<Bool, Error> = .failure(AuthManager.Error.credentialsNotFound)
    
    enum ReceivedMessage: Equatable {
        case setUserSession
        case storeCredentials
        case isBiometryEnabled
        case isBiometryForFirebaseGuaranteed
    }
    
    override func setUserSession(user: FirebaseAuth.User?) {
        receivedMessages.append(.setUserSession)
    }
    
    override func storeCredentialsInKeychain(email: String, password: String) {
        receivedMessages.append(.storeCredentials)
    }
    
    func completesIsBiometryEnabled(with error: Error, at index: Int = 0) {
        resultIsBiometryEnabledResult = .failure(error)
    }
    
    func completesIsBiometryEnabledSuccesfully(with result: Bool, at index: Int = 0) {
        resultIsBiometryEnabledResult = .success(result)
    }
    
    func completesIsBiometryForFirebaseGuaranteed(with error: Error, at index: Int = 0) {
        resultIsBiometryForFirebaseGuaranteed = .failure(error)
    }
    
    func completesSuccesfullyIsBiometryForFirebaseGuaranteed(with result: Bool, at index: Int = 0) {
        resultIsBiometryForFirebaseGuaranteed = .success(result)
    }
    
    override func isBiometryEnabled() -> Bool {
        receivedMessages.append(.isBiometryEnabled)
        return (try? resultIsBiometryEnabledResult.get()) ?? false
    }
    
    override func isBiometryForFirebaseGuaranteed() -> Bool {
        receivedMessages.append(.isBiometryForFirebaseGuaranteed)
        return (try? resultIsBiometryForFirebaseGuaranteed.get()) ?? false
    }
}
