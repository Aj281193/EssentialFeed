//
//  Paginated.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 27/08/23.
//

import Foundation

public struct Paginated<Item> {
  
    public typealias LoadMoreCompletion = (Result<Self, Swift.Error>) -> Void
    public let items: [Item]
    public let loadMore: ((@escaping LoadMoreCompletion) -> Void)?
    
    public init(items: [Item], loadMore: ((@escaping LoadMoreCompletion) -> Void)? = nil) {
        self.items = items
        self.loadMore = loadMore
    }
    
}
