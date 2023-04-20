//
//  FeedUIIntegrationTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Ashish Jaiswal on 20/04/23.
//

import Foundation
import EssentialFeed

class LoaderSpy: FeedLoader, FeedImageDataLoader {
  
    //MARK: FeedLoader
    private var feedRequests = [(FeedLoader.Result) -> Void]()
   
    var loadFeedCallCount: Int {
        return feedRequests.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        feedRequests.append(completion)
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
        feedRequests[index](.success(feed))
    }
    
    func completeFeedLoadingWithError(at index: Int) {
        let error = NSError(domain: "an error", code: 0)
        feedRequests[index](.failure(error))
    }
    
    //MARK: ImageDataLoader
    
    var loadedImageURLs: [URL] {
        return imageRequest.map { $0.url }
    }
    
    private struct TaskSpy: FeedImageDataLoaderTask {
        let cancelCallback: () -> Void
        
        func cancel() {
            cancelCallback()
        }
    }
    
    private var imageRequest = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    
    private(set) var cancelledImageURLs = [URL]()
    
  
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        imageRequest.append((url,completion))
        return TaskSpy { [weak self] in  self?.cancelledImageURLs.append(url)  }
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int) {
        imageRequest[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError( at index: Int) {
        let error = NSError(domain: "any Error", code: 0)
        imageRequest[index].completion(.failure(error))
    }
    
    
    func completedImageLoadingWithError(at index: Int) {
        let error = NSError(domain: "any error", code: 0)
        imageRequest[index].completion(.failure(error))
    }
}
