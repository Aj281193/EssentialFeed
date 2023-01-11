//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 11/01/23.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    public init() {}
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
      
    }
    
}
