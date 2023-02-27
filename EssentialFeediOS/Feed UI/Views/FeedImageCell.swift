//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 30/01/23.
//

import UIKit

public class FeedImageCell: UITableViewCell {

    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var feedImageContainer: UIView!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    
    @IBOutlet private(set) public var feedImageRetryButton: UIButton!
    
    var retry: (() -> Void)?
    var onReuse: (() -> Void)?
    
    @IBAction private func retryButtonTapped() {
        retry?()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        onReuse?()
    }
}
