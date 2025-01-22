//
//  RSComment.swift
//  ViewInspectorTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//

import Foundation


public struct RSComment: Identifiable {
    public let id: UUID
    public let userID: String
    public let username: String
    public let text: String
    public let date: Date
    public let idFirebaseDocument: String
    public let profileImageURL: String
    
    public init(id: UUID, userID: String, username: String, text: String, date: Date, idFirebaseDocument: String, profileImageURL: String) {
        self.id = id
        self.userID = userID
        self.username = username
        self.text = text
        self.date = date
        self.profileImageURL = profileImageURL
        self.idFirebaseDocument = idFirebaseDocument
    }
    
    public func timeFormatted() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full 
        
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 0 {
            return formatter.localizedString(for: date, relativeTo: now)
        } else if let hour = components.hour, hour > 0 {
            return formatter.localizedString(for: date, relativeTo: now)
        } else if let minute = components.minute, minute > 0 {
            return formatter.localizedString(for: date, relativeTo: now)
        } else {
            return "Just now"
        }
    }
    
    static func getISO8601StringFromDate(_ date: Date) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Include fractional seconds if needed
        isoFormatter.timeZone = TimeZone.current
        
        return isoFormatter.string(from: date)
    }
    
    static func getDateFromFirebaseString(_ dateString: String) -> Date {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Handle fractional seconds if present
        isoFormatter.timeZone = TimeZone.current
        
        return isoFormatter.date(from: dateString) ?? Date()
    }
}
