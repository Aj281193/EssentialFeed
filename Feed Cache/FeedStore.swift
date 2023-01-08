//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 28/12/22.
//

import Foundation

public enum RetrieveCaheFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timeStamp: Date)
    case failure(Error)
}
public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCaheFeedResult) -> Void
    
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


