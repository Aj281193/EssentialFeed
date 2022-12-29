//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 17/12/22.
//

import Foundation

public enum FeedLoaderResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping(FeedLoaderResult) -> Void)
}
