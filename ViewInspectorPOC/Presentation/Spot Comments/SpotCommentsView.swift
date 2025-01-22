//
//  CommentsView.swift
//  RemoteSpotiOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 14/1/25.
//

import SwiftUI

public struct SpotCommentsView: View {
    @ObservedObject var viewModel: SpotCommentsViewModel
    @State private var commentText: String = ""
    
    public init(viewModel: SpotCommentsViewModel) {
        self.viewModel = viewModel
        self.commentText = ""
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
          
            Text("Comments")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 12)
                .opacity(!viewModel.comments.isEmpty ? 1 : 0)
                
            List {
                ForEach(viewModel.comments) { comment in
                    SpotCommentCell(comment: comment, isLoading: $viewModel.isLoading)
                        .swipeActions(edge: .trailing) {
                            performSwipeActionOnTheSpotCell(comment: comment)
                        }
                }
            }
            
            .listStyle(PlainListStyle())
        }
        .refreshable {
            viewModel.fetchComments()
        }
    }
    
    @ViewBuilder
    private func performSwipeActionOnTheSpotCell(comment: RSComment) -> some View {
        let currentUserId = viewModel.authManager.currentUserId
        
        if comment.userID == currentUserId {
            Button(role: .destructive) {
                viewModel.removeComment(comment: comment, currentUserId: currentUserId)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

private struct StubCommentsLoader: AddCommentLoader {
    func addComment(_ comment: RSComment) async throws -> AddCommentLoader.Result {
        return .failure(MockLoaderError())
    }
    
    struct MockLoaderError: Error {}
}

