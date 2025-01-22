//
//  FirebaseCollectionProtocol.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//

import FirebaseFirestore

public protocol FirebaseCollectionProtocol {
    @available(*, deprecated)
    func getDocuments(completion: @escaping (QuerySnapshot?, (any Error)?) -> Void)
    func getDocuments() async throws -> QuerySnapshot
}

public protocol FirebaseQueryProtocol {
    func whereFieldFirebase(_ field: String, isGreaterThanOrEqualTo value: Any) -> FirebaseQueryProtocol
    func whereFieldFirebase(_ field: String, isLessThanOrEqualTo value: Any) -> FirebaseQueryProtocol
    func whereFieldFirebase(_ field: String, isEqualTo value: Any) -> FirebaseQueryProtocol
    func getDocumentsFirebase() async throws -> QuerySnapshot
}

extension FirebaseCollectionProtocol {
    public func getDocuments() async throws -> QuerySnapshot {
        let group = DispatchGroup()
        group.enter()
        
        var result: QuerySnapshot?
        var errorReceived: Error?
        
        getDocuments { querySnapshot, error in
            if let querySnapshot {
                result = querySnapshot
            } else if let error {
                errorReceived = error
            }
            group.leave()
        }
        
        group.wait()
        if let result {
            return result
        } else {
            throw errorReceived!
        }
    }
    
    public func getDocuments(completion: @escaping ((any QuerySnapshot)?, (any Error)?) -> Void) {}
}
// MARK: - Test purposes

// Protocol that mirrors a Querysnapshot
public protocol QuerySnapshot {
    var documents: [QueryDocumentSnapshotProtocol] { get }
}

// Protocol that mirrors the essential properties and methods from QueryDocumentSnapshot
public protocol QueryDocumentSnapshotProtocol {
    var data: [String: Any] { get }
}

struct QuerySnapshotImpl: QuerySnapshot {
    var documents: [any QueryDocumentSnapshotProtocol]
    
    public init(from firebaseSnapshot: FirebaseFirestore.QuerySnapshot) {
        self.documents = firebaseSnapshot.documents.map { DocumentSnapshot(from: $0) }
    }
}
struct DocumentSnapshot: QueryDocumentSnapshotProtocol {
    let data: [String: Any]
    init(from firebaseDocument: FirebaseFirestore.DocumentSnapshot) {
        self.data = firebaseDocument.data() ?? [:]
    }
}


// IMPLEMENTACION Query: FirebaseQueryProtocol

/////////////////////
///
///
///
public class FirebaseQueryWrapper: FirebaseQueryProtocol {
    private let query: Query
    
    public init(query: Query) {
        self.query = query
    }
    
    public func whereFieldFirebase(_ field: String, isGreaterThanOrEqualTo value: Any) -> any FirebaseQueryProtocol {
        let newQuery = query.whereField(field, isGreaterThanOrEqualTo: value)
        return FirebaseQueryWrapper(query: newQuery)
    }
    
    public func whereFieldFirebase(_ field: String, isLessThanOrEqualTo value: Any) -> any FirebaseQueryProtocol {
        let newQuery = query.whereField(field, isLessThanOrEqualTo: value)
        return FirebaseQueryWrapper(query: newQuery)
    }
    
    public func whereFieldFirebase(_ field: String, isEqualTo value: Any) -> any FirebaseQueryProtocol {
        let newQuery = query.whereField(field, isEqualTo: value)
        return FirebaseQueryWrapper(query: newQuery)
    }
    
    public func getDocumentsFirebase() async throws -> QuerySnapshot {
        let snapshot = try await query.getDocuments()
        return FirebaseQuerySnapshotWrapper(snapshot: query.convertFromQueryToCustomQuerySnapshot(snapshot))
    }
}

public class FirebaseQuerySnapshotWrapper: QuerySnapshot {
    private let snapshot: QuerySnapshot
    
    public init(snapshot: QuerySnapshot) {
        self.snapshot = snapshot
    }
    
    public var documents: [QueryDocumentSnapshotProtocol] {
        return snapshot.documents.map { FirebaseQueryDocumentSnapshotWrapper(document: $0) }
    }
}

public class FirebaseQueryDocumentSnapshotWrapper: QueryDocumentSnapshotProtocol {
    private let document: QueryDocumentSnapshotProtocol
    
    public init(document: QueryDocumentSnapshotProtocol) {
        self.document = document
    }
    
    public var data: [String: Any] {
        return document.data
    }
}


