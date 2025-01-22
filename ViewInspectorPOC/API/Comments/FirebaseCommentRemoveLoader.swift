//
//  FirebaseCommentRemoveLoader.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//

public class FirebaseCommentRemoveLoader: CommentRemoveLoader {
    let docReferenceRemove: FirebaseDocumentDeleteReferenceProtocol
    
    public init(docReferenceRemove: FirebaseDocumentDeleteReferenceProtocol) {
        self.docReferenceRemove = docReferenceRemove
    }
    
    public func delete() async throws {
        do {
            try await docReferenceRemove.deleteFirebase()
        } catch {
            throw error
        }
    }
}
