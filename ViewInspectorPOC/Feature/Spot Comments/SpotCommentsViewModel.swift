//
//  SpotCommentsViewModel.swift
//  RemoteSpot
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 14/1/25.
//

//
//  SignUpViewModel.swift
//  RemoteSpot
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 22/12/24.
//



import SwiftUI
import Observation
import FirebaseFirestore
import FirebaseAuth

public typealias CommentRemoveLoaderFactory = (String) -> FirebaseCommentRemoveLoader

@Observable
public class SpotCommentsViewModel: ObservableObject {
    
    private let spotID: String
    private let commentsAddLoader: AddCommentLoader
    private let commentRemoveLoaderFactory: CommentRemoveLoaderFactory
    public let authManager: AuthManagerProtocol
    
    public var comments: [RSComment] = []
    public var commentRemoveLoader: FirebaseCommentRemoveLoader?
    private var commentDocumentID: String = ""
    public var isLoading: Bool = false
    
    public init(spotID: String, commentsAddLoader: AddCommentLoader, commentRemoveLoaderFactory: @escaping CommentRemoveLoaderFactory, authManager: AuthManagerProtocol) {
        self.spotID = spotID
        self.commentsAddLoader = commentsAddLoader
        self.commentRemoveLoaderFactory = commentRemoveLoaderFactory
        self.authManager = authManager 
        
        configureSkeletonData()
       
                self.fetchComments()
            
        
    }
    
    public func addComment(comment: RSComment) async throws  {
        do {
            let result = try await commentsAddLoader.addComment(comment)
            
            switch result {
            case .success:
                Task {
                   fetchComments()
                }
                
            case .failure(let error):
                self.isLoading = false
                throw error
            }
        } catch {
            throw error
        }
    }
    
    // TODO: Move addSnapshotListener with AsyncStream into a Mockable Protocol for testing
    public func fetchComments() {
        Constants.CollectionFirebase.spots.document(spotID).collection(Constants.CollectionFirebase.comments)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                guard let documents = snapshot?.documents else {
                    print("Error fetching comments: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                do {
            
                    self.comments = try CommentsFirebaseMapper.mapDocuments(documents).map { $0.toModel() }
                    self.isLoading = false
                    
                } catch {
                    //TODO: Handle error
//                    DispatchQueue.main.async { [weak self] in
                        //guard let self = self else {return }
                        self.isLoading = false
//                    }
                }
            }
    }
    
    @MainActor
    public func uploadComment(_ commentText: String) {
        guard let user = authManager.user else { return }
        
        let comment = RSComment(id: UUID(), userID: user.uid, username: user.userName, text: commentText, date: Date(), idFirebaseDocument: "", profileImageURL: user.profileImageUrl)
        Task {
            do {
                isLoading = true
                try await addComment(comment: comment)
                isLoading = false
            } catch {
                isLoading = false
            }
        }
    }
    
    public func removeComment(comment commentToRemove: RSComment, currentUserId: String?) {
        
        if commentToRemove.userID == currentUserId {
            commentRemoveLoader = commentRemoveLoaderFactory(commentToRemove.idFirebaseDocument)
            performRemoveCommentAction()
        }
    }
    
    private func performRemoveCommentAction() {
        Task {
            do {
                try await commentRemoveLoader?.delete()
                await fetchComments()
            } catch {
                //TODO: Handle error
            }
        }
    }
    
    public func configureSkeletonData() {
        comments = getMockComments()
        isLoading = true
    }
}

private extension SpotCommentsViewModel {
    private func getMockComments() -> [RSComment] {
        [
            RSComment(
                id: UUID(),
                userID: "user001",
                username: "JohnDoe",
                text: "This is an amazing spot! Highly recommend it.",
                date: Date(),
                idFirebaseDocument: "firebase001",
                profileImageURL: "https://www.guiadecadiz.com/playas/tarifa/valdevaqueros-invierno.jpg"
            ),
            RSComment(
                id: UUID(),
                userID: "user002",
                username: "JaneSmith",
                text: "Had a great time here. Perfect for remote work.",
                date: Date().addingTimeInterval(-3600), // 1 hour ago
                idFirebaseDocument: "firebase002",
                profileImageURL: "https://www.guiadecadiz.com/playas/tarifa/valdevaqueros-invierno.jpg"
            ),
            RSComment(
                id: UUID(),
                userID: "user003",
                username: "SamWilson",
                text: "WiFi was a bit spotty, but the coffee was great!",
                date: Date().addingTimeInterval(-7200), // 2 hours ago
                idFirebaseDocument: "firebase003",
                profileImageURL: "https://www.guiadecadiz.com/playas/tarifa/valdevaqueros-invierno.jpg"
            ),
            RSComment(
                id: UUID(),
                userID: "user004",
                username: "EmilyClark",
                text: "Loved the ambiance and the friendly staff!",
                date: Date().addingTimeInterval(-86400), // 1 day ago
                idFirebaseDocument: "firebase004",
                profileImageURL: "https://www.guiadecadiz.com/playas/tarifa/valdevaqueros-invierno.jpg"
            ),
            RSComment(
                id: UUID(),
                userID: "user005",
                username: "MichaelBrown",
                text: "Not my favorite place, but it's decent for a quick stop.",
                date: Date().addingTimeInterval(-172800), // 2 days ago
                idFirebaseDocument: "firebase005",
                profileImageURL: "https://www.guiadecadiz.com/playas/tarifa/valdevaqueros-invierno.jpg"
            ),
            RSComment(
                id: UUID(),
                userID: "user004",
                username: "EmilyClark",
                text: "Loved the ambiance and the friendly staff!",
                date: Date().addingTimeInterval(-86400), // 1 day ago
                idFirebaseDocument: "firebase004",
                profileImageURL: "https://www.guiadecadiz.com/playas/tarifa/valdevaqueros-invierno.jpg"
            ),
            RSComment(
                id: UUID(),
                userID: "user005",
                username: "MichaelBrown",
                text: "Not my favorite place, but it's decent for a quick stop.",
                date: Date().addingTimeInterval(-172800), // 2 days ago
                idFirebaseDocument: "firebase005",
                profileImageURL: "https://www.guiadecadiz.com/playas/tarifa/valdevaqueros-invierno.jpg"
            )
        ]
    }
}

