//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Ashish Jaiswal on 08/04/23.
//

import Foundation
import EssentialFeed

public class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    public init(_ result: FeedLoader.Result) {
        self.result = result
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
