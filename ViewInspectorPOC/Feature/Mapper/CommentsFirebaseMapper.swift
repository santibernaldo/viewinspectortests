//
//  CommentsFirebaseMapper.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//

import FirebaseFirestore

internal final class CommentsFirebaseMapper {
    public class RemoteCommentDTO: Decodable {
        private let idDocument: String
        private let userID: String
        private let username: String
        private let text: String
        private let timestamp: String
        private let profileImageURL: String
        
        init(idDocument: String, userID: String, username: String, text: String, timestamp: String, profileImageURL: String) {
            self.idDocument = idDocument
            self.userID = userID
            self.username = username
            self.text = text
            self.timestamp = timestamp
            self.profileImageURL = profileImageURL
        }
        
        func toModel() -> RSComment {
            return RSComment(id: UUID(), userID: userID, username: username, text: text, date: RSComment.getDateFromFirebaseString(timestamp), idFirebaseDocument: idDocument, profileImageURL: profileImageURL)
        }
    }
    
    private init() {}
    
    // TODO: Maybe not getting always .invalidData, this is a code smell
    public static func map(_ comment: RSComment) -> [String: Any] {
        let commentData: [String: Any] = [
            "userID": comment.userID,
            "username": comment.username,
            "text": comment.text,
            "timestamp": RSComment.getISO8601StringFromDate(comment.date),
            "profileImageURL": comment.profileImageURL
        ]
        
        return commentData
    }
    
    public static func map(_ idDocument: String) -> [String: Any] {
        let data: [String: Any] = [
            "idDocument": idDocument
        ]
        
        return data
    }
    
    // TODO: Maybe not getting always .invalidData, this is a code smell
    private static func getDTORemoteObject(dataDict: [String: Any]) throws -> RemoteCommentDTO? {
        guard let data = try? JSONSerialization.data(withJSONObject: dataDict) else { return nil }
        
        let decoder = JSONDecoder()
        var comment: RemoteCommentDTO
        
        do {
            comment = try decoder.decode(RemoteCommentDTO.self, from: data)
            return comment
        } catch {
            throw FirebaseRemoteAddCommentsLoader.Error.mappingToDictError
        }
    }
    
    // TODO: Maybe not getting always .invalidData, this is a code smell
    public static func mapDocuments(_ documents: [QueryDocumentSnapshot]?) throws -> [RemoteCommentDTO] {
        guard let documents = documents else { throw RemoteFirebaseSpotLoader.Error.emptySnapshot }
        
        let comments: [RemoteCommentDTO] = try documents.compactMap { document in
            do {
                if let commentResponse = try getDTORemoteObject(dataDict: document.data()) {
                    return commentResponse
                } else {
                    throw FirebaseRemoteAddCommentsLoader.Error.mapDocumentError
                }
            } catch {
                throw FirebaseRemoteAddCommentsLoader.Error.mapDocumentError
            }
        }
        
        return comments
    }
    
}
