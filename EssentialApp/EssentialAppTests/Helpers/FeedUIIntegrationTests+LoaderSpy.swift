//
//  FeedUIIntegrationTests+LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Ashish Jaiswal on 13/08/23.
//

import UIKit
import EssentialApp
import EssentialFeed
import EssentialFeediOS
import Combine

extension FeedUIIntegrationTests {
    class LoaderSpy: FeedImageDataLoader {
        
        //MARK: FeedLoader
        private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
        
        
        func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
            let publisher = PassthroughSubject<Paginated<FeedImage>,Error>()
            feedRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        var loadFeedCallCount: Int {
            return feedRequests.count
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index].send(Paginated(items: feed))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index].send(completion: .failure(error))
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
}
