//
//  FeedViewControllerTestsHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Ashish Jaiswal on 27/02/23.
//

import XCTest
import EssentialFeediOS

extension FeedViewController {
    
    var errorMessage: String? {
        return errorView?.message
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulatedFeedImageViewVNearVisible(at index: Int) {
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: feedImageSection)
        ds?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulatedFeedImageViewNotNearVisible(at row: Int) {
        simulatedFeedImageViewVNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    
    func numbderOfRenderFeedImageView() -> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    
    @discardableResult
    func simulatedFeedImageViewVisible(at index: Int)  -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulatedFeedImageViewNotVisible(at row: Int) -> FeedImageCell {
        let view = simulatedFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        return view!
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulatedFeedImageViewVisible(at: index)?.renderImage
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var feedImageSection: Int {
        return 0
    }
}





