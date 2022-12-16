//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 17/12/22.
//

import Foundation


public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public func load(completion: @escaping (Error) -> Void = { _ in}) {
        client.get(from: url) { error in
            completion(.connectivity)
        }
    }
}
