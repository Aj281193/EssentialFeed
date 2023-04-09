//
//  FeedImageDataLoaderSpy.swift
//  EssentialAppTests
//
//  Created by Ashish Jaiswal on 09/04/23.
//

import Foundation
import EssentialFeed

class FeedImageDataLoaderSpy: FeedImageDataLoader {

    private(set) var messages = [(url: URL, completion:  (FeedImageDataLoader.Result) -> Void)]()
    var cancelledURLs = [URL]()
    
    var loadedURLs: [URL] {
        return messages.map { $0.url }
    }
    
    private struct Task: FeedImageDataLoaderTask {
        let callback: () -> Void
        func cancel() { callback() }
    }
    
    func complete(with data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }
    
    func complete(with error: NSError,at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        messages.append((url,completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
}
