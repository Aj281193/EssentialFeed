//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 21/03/23.
//

import Foundation

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataFromURL url: URL) throws -> Data?
}
