//
//  SpotCommentsUIComposer.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//

import SwiftUI
import FirebaseFirestore

public struct SpotCommentsUIComposer {
    
    @MainActor public static func compose(spot: SpotItem, authManager: AuthManagerProtocol, commentsLoader: AddCommentLoader) -> (view: SpotCommentsView, viewModel: SpotCommentsViewModel) {
        let removeLoaderFactory: CommentRemoveLoaderFactory = { commentDocumentID in
            FirebaseCommentRemoveLoader(docReferenceRemove: Constants.CollectionFirebase.spots.document(spot.idFirebaseDocument).collection(Constants.CollectionFirebase.comments).document(commentDocumentID))
        }
        
        let viewModel = SpotCommentsViewModel(spotID: spot.idFirebaseDocument, commentsAddLoader: commentsLoader, commentRemoveLoaderFactory: removeLoaderFactory, authManager: authManager)
        
        let spotCommentsView = SpotCommentsView(viewModel: viewModel)
        return (spotCommentsView, viewModel)
    }
    
}


private final class MainQueueDispatchDecorator: AddCommentLoader {
    private let decoratee: AddCommentLoader
    
    init(decoratee: AddCommentLoader) {
        self.decoratee = decoratee
    }
    
    func addComment(_ comment: RSComment) async throws -> AddCommentLoader.Result {
        let result = try await decoratee.addComment(comment)
        // Ensure the result is returned on the main thread
        if Thread.isMainThread {
            return result
        } else {
            return await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    continuation.resume(returning: result)
                }
            }
        }
    }
}
