//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 30/01/23.
//

import UIKit

public class FeedImageCell: UITableViewCell {

    public let locationContainer = UIView()
    public let feedImageContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageView = UIImageView()
    
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var retry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        retry?()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
