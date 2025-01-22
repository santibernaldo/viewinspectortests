//
//  CollectionReference+FirebaseCollection.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//



import FirebaseFirestore

extension Query: FirebaseQueryProtocol {
    
    public func whereFieldFirebase(_ field: String, isGreaterThanOrEqualTo value: Any) -> any FirebaseQueryProtocol {
        let newQuery = self.whereField(field, isGreaterThanOrEqualTo: value)
        return FirebaseQueryWrapper(query: newQuery)
    }
    
    public func whereFieldFirebase(_ field: String, isLessThanOrEqualTo value: Any) -> any FirebaseQueryProtocol {
        let newQuery = self.whereField(field, isLessThanOrEqualTo: value)
        return FirebaseQueryWrapper(query: newQuery)
    }
    
    public func whereFieldFirebase(_ field: String, isEqualTo value: Any) -> any FirebaseQueryProtocol {
        let newQuery = self.whereField(field, isEqualTo: value)
        return FirebaseQueryWrapper(query: newQuery)
    }
    
    public func getDocumentsFirebase() async throws -> QuerySnapshot {
        let snapshot = try await self.getDocuments()
        return FirebaseQuerySnapshotWrapper(snapshot: convertFromQueryToCustomQuerySnapshot(snapshot))
    }
    
    public func convertFromQueryToCustomQuerySnapshot(_ querySnapshot: FirebaseFirestore.QuerySnapshot) -> QuerySnapshot {
        return QuerySnapshotImpl(from: querySnapshot)
    }
}

extension CollectionReference: FirebaseCollectionProtocol {
    
    public func getDocuments(completion: @escaping (QuerySnapshot?, Error?) -> Void) {
        self.performOriginalGetDocuments { (querySnapshot: FirebaseFirestore.QuerySnapshot?, error: Error?) in
            
            // Convert `FirebaseFirestore.QuerySnapshot` to your custom `QuerySnapshot` type
            let convertedSnapshot = querySnapshot.map { self.convertToCustomQuerySnapshot($0) }
            completion(convertedSnapshot, error)
        }
    }

    /// Helper to invoke the original `getDocuments` method directly
    private func performOriginalGetDocuments(completion: @escaping (FirebaseFirestore.QuerySnapshot?, Error?) -> Void) {
        // Use a new instance of `CollectionReference` to avoid recursion
        
        getDocuments { (querySnapshot: FirebaseFirestore.QuerySnapshot?, error: Error?) in
            completion(querySnapshot, error)
        }
    }

    /// Converts `FirebaseFirestore.QuerySnapshot` to your custom `QuerySnapshot` type
   private func convertToCustomQuerySnapshot(_ querySnapshot: FirebaseFirestore.QuerySnapshot) -> QuerySnapshot {
        return QuerySnapshotImpl(from: querySnapshot)
    }
}
