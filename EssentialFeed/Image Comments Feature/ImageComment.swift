//
//  ImageComment.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 14/07/23.
//

import Foundation

public struct ImageComment: Equatable {
    public let id: UUID
    public let message: String
    public let createdAt: Date
    public let username: String
    
    public init(id: UUID, message: String, createdAt: Date, userName: String) {
        self.id = id
        self.message = message
        self.createdAt = createdAt
        self.username = userName
    }
}
