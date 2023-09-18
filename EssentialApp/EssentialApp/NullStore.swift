//
//  NullStore.swift
//  EssentialApp
//
//  Created by Ashish Jaiswal on 12/09/23.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore & FeedImageDataStore {
    
    // FeedImageDataStore
    func insert(_ data: Data, for url: URL) throws { }
    
    func retrieve(dataFromURL url: URL) throws -> Data? { .none }
    
    // FeedStore
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
}
