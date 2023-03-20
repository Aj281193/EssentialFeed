//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 21/03/23.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    typealias InsertionResult = Swift.Result<Void,Error>
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrieve(dataFromURL url: URL, completion: @escaping (Result) -> Void)
}
