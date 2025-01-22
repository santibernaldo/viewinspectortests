//
//  FirebaseRemoteCommentsLoader.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//

public class FirebaseRemoteAddCommentsLoader: AddCommentLoader {

    private let collection: FirebaseCollectionAddDocumentProtocol
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case mappingToDictError
        case emptyComment
        case mapDocumentError
        case decodingDateFromFirebase
    }
    
    public init(collection: FirebaseCollectionAddDocumentProtocol) {
        self.collection = collection
    }
    
    public func addComment(_ comment: RSComment) async throws -> AddCommentLoader.Result {
        guard !comment.text.isEmpty else { return .failure(Error.emptyComment) }
        
        do {
            let data = CommentsFirebaseMapper.map(comment)
            let result = try await collection.addDocumentFirebase(data: data)
            try await result.updateDataFirebase(CommentsFirebaseMapper.map(result.documentIDFirebase))
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}

private struct GetResultError: Error {}
