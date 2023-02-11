//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 11/02/23.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let feedloader: FeedLoader
    
    init(feedloader: FeedLoader) {
        self.feedloader = feedloader
    }
    
    var onLoadingSateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
    func loadFeed() {
        onLoadingSateChange?(true)
        feedloader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingSateChange?(false)
        }
    }
    
}
