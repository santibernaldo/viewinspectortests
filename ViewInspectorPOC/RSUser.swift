//
//  RSUser.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//

import SwiftUI

@Observable
public class RSUser: Identifiable, Equatable {
    public var id: String {
        return uid
    }
    public let fullName: String?
    public let profileImageUrl: String
    public let userName: String
    public let uid: String
    let isFollowed: Bool?
    let email: String
    
   public init(fullName: String?, profileImageUrl: String, userName: String, uid: String, isFollowed: Bool?, email: String) {
        self.fullName = fullName
        self.profileImageUrl = profileImageUrl
        self.userName = userName
        self.uid = uid
        self.isFollowed = isFollowed
        self.email = email
    }

    public init() {
        self.fullName = nil
        self.profileImageUrl = ""
        self.userName = ""
        self.uid = ""
        self.isFollowed = false
        self.email = ""
    }
    
    // Conformance to Equatable
    public static func == (lhs: RSUser, rhs: RSUser) -> Bool {
        return lhs.uid == rhs.uid
    }
    
}

