//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 30/12/22.
//

import XCTest
import EssentialFeed

class FeedStoreSpy: FeedStore {
  
    enum ReceviedMessage: Equatable {
        case deleteCacheFeed
        case insert([LocalFeedImage],Date)
        case retrieve
    }
    
    private(set) var receivedMessgae = [ReceviedMessage]()
    
    private var deleteCompletion = [DeletionCompletion]()
    private var insertionCompletion = [InsertionCompletion]()
    private var retrievalCompletion = [RetrievalCompletion]()
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deleteCompletion.append(completion)
        receivedMessgae.append(.deleteCacheFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deleteCompletion[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deleteCompletion[index](nil)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletion[index](nil)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletion[index](error)
    }
    
    func completeRetrieval(with error: Error,at index: Int = 0) {
        retrievalCompletion[index](error)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletion.append(completion)
        receivedMessgae.append(.insert(feed, timestamp))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletion.append(completion)
        receivedMessgae.append(.retrieve)
    }
}
