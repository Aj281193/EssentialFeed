//
//  FeedViewControllerTestsHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Ashish Jaiswal on 27/02/23.
//

import XCTest
import EssentialFeediOS

extension ListViewController {
    
    public override func loadViewIfNeeded() {
          super.loadViewIfNeeded()

          tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    var errorMessage: String? {
        return errorView.message
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
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
        return tableView.numberOfSections == 0 ? 0 :
            tableView.numberOfRows(inSection: feedImageSection)
    }
    
    @discardableResult
    func simulatedFeedImageViewVisible(at index: Int)  -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        simulatedFeedImageViewVisible(at: index)?.renderImage
    }
    
    @discardableResult
    func simulatedFeedImageViewNotVisible(at row: Int) -> FeedImageCell {
        let view = simulatedFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        return view!
    }
    
  
    @discardableResult
    func simulateFeedImageBecomingVisibleAgain(at row: Int) -> FeedImageCell? {
        let view = simulatedFeedImageViewNotVisible(at: row)

        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, willDisplay: view, forRowAt: index)

        return view
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numbderOfRenderFeedImageView() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var feedImageSection: Int {
        return 0
    }
}





