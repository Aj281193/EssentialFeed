//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 08/02/23.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController: FeedImageView {
    
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }
    
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell?.locationContainer.isHidden = viewModel.hasLoaction
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.feedImageView.setImageAnimated(viewModel.image)
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.retry = delegate.didRequestImage
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        releaseCellAfterReuse()
        delegate.didCancelImageRequest()
    }
    
    func releaseCellAfterReuse() {
        cell = nil
    }
}

