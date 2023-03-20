//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 21/03/23.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataFromURL url: URL, completion: @escaping (Result) -> Void)
}
