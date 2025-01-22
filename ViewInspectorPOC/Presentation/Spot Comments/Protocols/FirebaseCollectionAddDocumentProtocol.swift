//
//  FirebaseCollectionAddDocumentProtocol.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//

import FirebaseFirestore

// Collection Reference Add Document
public protocol FirebaseCollectionAddDocumentProtocol {
    func addDocumentFirebase(data: [String: Any]) async throws -> FirebaseDocumentUpdateReferenceProtocol
}

extension CollectionReference: FirebaseCollectionAddDocumentProtocol {
   
    public func addDocumentFirebase(data: [String: Any]) async throws -> FirebaseDocumentUpdateReferenceProtocol {
        return try await self.performAddDocument(data: data)
    }
    
    private func performAddDocument(data: [String: Any]) async throws -> FirebaseDocumentUpdateReferenceProtocol {
        do {
            let documentReference = try await addDocument(data: data)
            return FirebaseDocumentUpdateReferenceWrapper(documentReference: documentReference)
        } catch {
            throw error
        }
    }
}

// Collection Reference Update Document
public protocol FirebaseDocumentUpdateReferenceProtocol {
    var documentIDFirebase: String { get }
    func updateDataFirebase(_ data: [String: Any]) async throws
}

extension DocumentReference: FirebaseDocumentUpdateReferenceProtocol {
    public var documentIDFirebase: String {
        self.documentID
    }
    
    public func updateDataFirebase(_ data: [String: Any]) async throws {
        try await self.updateData(data)
    }
}

public class FirebaseDocumentUpdateReferenceWrapper: FirebaseDocumentUpdateReferenceProtocol {
    public var documentIDFirebase: String {
        return documentID
    }
    
    private let documentReference: DocumentReference
    
    public var documentID: String {
        return documentReference.documentID
    }
    
    public init(documentReference: DocumentReference) {
        self.documentReference = documentReference
    }
    
    public func updateDataFirebase(_ data: [String : Any]) async throws {
        try await documentReference.updateData(data)
    }
}

// Collection Reference Remove Document
public protocol FirebaseDocumentDeleteReferenceProtocol {
    func deleteFirebase() async throws
}

extension DocumentReference: FirebaseDocumentDeleteReferenceProtocol {
    public func deleteFirebase() async throws {
        try await self.delete()
    }
}
