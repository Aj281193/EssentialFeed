//
//  FeedImageCache.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 09/04/23.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
