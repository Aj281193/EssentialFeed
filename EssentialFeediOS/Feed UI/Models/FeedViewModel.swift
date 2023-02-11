//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 11/02/23.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
    private let feedloader: FeedLoader
    
    init(feedloader: FeedLoader) {
        self.feedloader = feedloader
    }
    
    var onChange:((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }
    
    func loadFeed() {
        isLoading = true
        feedloader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
            
        }
    }
    
}
