//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 08/02/23.
//

import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController: FeedImageView, ResourceView , ResourceLoadingView, ResourceErrorView {

    public typealias ResourceViewModel = UIImage
    
    private let viewModel: FeedImageViewModel<UIImage>
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    
    public init(viewModel: FeedImageViewModel<UIImage>, delegate: FeedImageCellControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.locationContainer.isHidden = viewModel.hasLoaction
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.retry = delegate.didRequestImage
        cell?.onReuse = { [weak self] in
            self?.releaseCellAfterReuse()
        }
        delegate.didRequestImage()
        return cell!
    }
    
    public func display(_ viewModel: FeedImageViewModel<UIImage>) { }
    
    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImageAnimated(viewModel)
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.feedImageRetryButton.isHidden = viewModel.message == nil
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

