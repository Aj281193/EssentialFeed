//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 17/12/22.
//

import Foundation


public final class RemoteFeedLoader {
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
    
    public enum Result: Equatable {
        case success([FeedItems])
        case failure(Error)
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                completion(self.map(data, response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        if let items = try? FeedItemMapper.map(data,response){
            return .success(items)
        } else {
            return .failure(.invalidData)
        }
    }
}

