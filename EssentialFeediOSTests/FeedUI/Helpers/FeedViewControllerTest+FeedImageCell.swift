//
//  FeedViewControllerTest+FeedImageCell.swift
//  EssentialFeediOSTests
//
//  Created by Ashish Jaiswal on 27/02/23.
//

import XCTest
import EssentialFeediOS

extension FeedImageCell {
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
    
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var isShowingRetryAction: Bool {
        return !feedImageRetryButton.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var renderImage: Data? {
        return feedImageView.image?.pngData()
    }
}
