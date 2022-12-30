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
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}


