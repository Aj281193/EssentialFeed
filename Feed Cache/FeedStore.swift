//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 28/12/22.
//

import Foundation

public typealias CacheFeed = (feed: [LocalFeedImage], timeStamp: Date)


public protocol FeedStore {
    typealias RetrievalResult = Result<CacheFeed?, Error>
    
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    /// The completion Handler can be invoked in any thread.
    /// Client are responsible to dispatch to appropriate thread if needed.
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    
    /// The completion Handler can be invoked in any thread.
    /// Client  are responsible to dispatch to appropriate thread if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion Handler can be invoked in any thread.
    /// Client  are responsible to dispatch to appropriate thread if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}


