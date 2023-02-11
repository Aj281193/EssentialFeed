//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 08/02/23.
//

import UIKit

final class FeedImageCellController {
    
    private let viewModel: FeedImageViewModel
    
    init(viewModel: FeedImageViewModel) {
        self.viewModel = viewModel
    }
    
    public func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImageData()
        return cell
    }
    
    func binded(_ cell: FeedImageCell) -> FeedImageCell {
        cell.locationContainer.isHidden = viewModel.hasLoaction
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.retry = viewModel.loadImageData
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            cell?.feedImageContainer.isShimmering = isLoading
        }
        
        viewModel.onShouldRetryButtonStateChange = { [weak cell] ishidden in
            cell?.feedImageRetryButton.isHidden = !ishidden
        }
       
        return cell
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelImageLoad()
    }
}
