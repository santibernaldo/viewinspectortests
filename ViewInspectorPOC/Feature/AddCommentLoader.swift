//
//  FirebaseCommentsLoader.swift
//  RemoteSpot
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 14/1/25.
//

public protocol AddCommentLoader {
    typealias Result = Swift.Result<(), Error>
    
    func addComment(_ comment: RSComment) async throws -> Result
}
