//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 21/03/23.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    
    typealias InsertionResult = Swift.Result<Void,Error>
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    func completeRetrieval(dataFromURL url: URL, completion: @escaping (RetrievalResult) -> Void)
}
