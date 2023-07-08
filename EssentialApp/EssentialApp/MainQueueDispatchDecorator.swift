//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 04/03/23.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping() -> Void) {
        
        guard Thread.isMainThread else { return  DispatchQueue.main.async(execute: completion) }
       
        completion()
    }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}
