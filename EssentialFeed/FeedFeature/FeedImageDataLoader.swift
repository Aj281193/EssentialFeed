//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 07/02/23.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}
public  protocol FeedImageDataLoader: AnyObject {
    typealias Result = Swift.Result<Data,Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
