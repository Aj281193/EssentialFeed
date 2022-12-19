//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 17/12/22.
//

import Foundation


public final class RemoteFeedLoader: FeedLoader {
   
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
   
    public typealias Result = FeedLoaderResult
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) {[weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(FeedItemMapper.map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }


}

