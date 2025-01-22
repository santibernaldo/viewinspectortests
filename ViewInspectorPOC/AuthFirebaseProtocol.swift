//
//  AuthFirebaseProtocol.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//


import SwiftUI
import FirebaseAuth
import LocalAuthentication
import FirebaseFirestore
 
public protocol AuthFirebaseProtocol {
    var currentUserFirebase: FirebaseAuth.User? { get }
    func signOutFirebase() throws
}

public class MockAuthFirebase: AuthFirebaseProtocol {
    public var currentUserFirebase: FirebaseAuth.User?
    
    public init() {}
    
    public func signOutFirebase() throws {
        currentUserFirebase = nil
    }
}

public protocol AuthManagerProtocol {
    var user: RSUser? { get set }
    var userSession: FirebaseAuth.User? { get set }
    var currentUserId: String { get }
    func setUserSession(user: FirebaseAuth.User?)
    func storeCredentialsInKeychain(email: String, password: String)
    func setUser(user: RSUser?)
    func isBiometryEnabled() -> Bool
    func isFaceIDAvailable() -> Bool
    func isBiometryForFirebaseGuaranteed() -> Bool
    func getCredentials() throws -> (email: String, password: String)
    func getBiometricsPermissions() async -> Bool
    func signOutUser() throws
}

extension Auth: AuthFirebaseProtocol {
    public var currentUserFirebase: FirebaseAuth.User? { self.currentUser }
    public func signOutFirebase() throws {
        try signOut()
    }
}

@Observable
open class AuthManager: ObservableObject, AuthManagerProtocol {
    public var user: RSUser?
    
   
    // Every time one of these properties change, it will publish its state to the classes where @EnvironmentObject of AuthViewModel is declared
    private let authService: AuthFirebaseProtocol
    public var userSession: FirebaseAuth.User?
    public var currentUserId: String {
        return user?.uid ?? "0"
    }
    
    public enum Error: Swift.Error {
        case credentialsNotFound
    }
        
    public init(authService: AuthFirebaseProtocol) {
        self.authService = authService
        // If currentUser is not nil, we logged in already
        userSession = authService.currentUserFirebase
        // Fetch user data if the session exists
        if userSession != nil {
            fetchUser()
        }
    }
    
    open func setUserSession(user: FirebaseAuth.User?) {
        self.userSession = user
    }
    
    open func setUser(user: RSUser?) {
        self.user = user
    }
    
    public func signOutUser() throws {
        do {
            try authService.signOutFirebase()

            userSession = nil
            user = nil
            return
        } catch {
            throw error
        }
    }
    
    func fetchUser() {
        
    }
    
    @discardableResult
    open func getCredentials() throws -> (email: String, password: String) {
        try getCredentialsFromKeychain()
    }
    
    open func isBiometryEnabled() -> Bool {
        return isBiometricAuthenticationAvailable() == (available: true, type: .touchID) || isBiometricAuthenticationAvailable() == (available: true, type: .faceID)
    }
    
    // If saved, we show the Biometry icon, if the user has Biometrics feature on his device
    open func storeCredentialsInKeychain(email: String, password: String) {
        let credentials = "\(email):\(password)"
        guard let data = credentials.data(using: .utf8) else { return }
        
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "firebaseUserCredentials",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        SecItemDelete(keychainQuery as CFDictionary)  // Eliminar entradas previas si existen
        let _ = SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    open func isBiometryForFirebaseGuaranteed() -> Bool {
        do {
            try getCredentials()
            return true
        } catch {
            return false
        }
    }
}

// Biometry Login
extension AuthManager {
    
    public func getBiometricsPermissions() async -> Bool {
        let context = LAContext()
        return await withCheckedContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Usa tu huella o Face ID para iniciar sesión") { success, error in
                if success {
                    // Recuperar el refresh token del Keychain
                    let keychainQuery: [String: Any] = [
                        kSecClass as String: kSecClassGenericPassword,
                        kSecAttrAccount as String: "firebaseRefreshToken",
                        kSecReturnData as String: true,
                        kSecMatchLimit as String: kSecMatchLimitOne
                    ]
                    
                    var dataTypeRef: AnyObject?
                    let status = SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)
                    
                    if status == errSecSuccess, let data = dataTypeRef as? Data, let _ = String(data: data, encoding: .utf8) {
                        // Reautenticar al usuario con el refresh token
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    private func isBiometricAuthenticationAvailable() -> (available: Bool, type: LABiometryType) {
        let context = LAContext()
        var error: NSError?
        
        // Verifica si el dispositivo admite biometría
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // Retorna el tipo de biometría disponible (Face ID o Touch ID)
            return (true, context.biometryType)
        } else {
            // Si no está disponible, devuelve false
            return (false, context.biometryType)
        }
    }
    
    public func isFaceIDAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?

        // Verifica si la biometría está disponible en el dispositivo
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // Retorna true solo si el tipo de biometría es Face ID
            return context.biometryType == .faceID
        }

        // Si no puede evaluar la biometría o el tipo no es Face ID, retorna false
        return false
    }
}

// Keychain
extension AuthManager {
    @discardableResult
    private func removeCredentialsFromKeychain() -> Bool {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "firebaseUserCredentials"
        ]
        
        let status = SecItemDelete(keychainQuery as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    private func getCredentialsFromKeychain() throws -> (email: String, password: String) {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "firebaseUserCredentials",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data,
           let credentials = String(data: data, encoding: .utf8) {
            let components = credentials.split(separator: ":")
            if components.count == 2 {
                return (email: String(components[0]), password: String(components[1]))
            }
        }
        
        throw Error.credentialsNotFound
    }
}

