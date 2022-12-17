//
//  FeedItems.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 17/12/22.
//

import Foundation

public struct FeedItems: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
