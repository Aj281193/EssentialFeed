//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 21/03/23.
//

import Foundation
import EssentialFeed

final class FeedImageDataStoreSpy: FeedImageDataStore {
    
    enum Message: Equatable {
        case retrieve(dataFor: URL)
        case insert(data: Data, url: URL)
    }
    
    private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private var insertionCompletions = [(FeedImageDataStore.InsertionResult) -> Void]()
    private(set) var receivedMessages = [Message]()
    
    
    func completeRetrieval(dataFromURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(dataFor: url))
        retrievalCompletions.append(completion)
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, url: url))
        insertionCompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
    
    func completeInsertion(With error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
}
