//
//  ImageCommentsCellController.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 05/08/23.
//

import UIKit
import EssentialFeed

public final class ImageCommentsCellController: CellController {
    
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.dateLabel.text = model.date
        cell.usernameLabel.text = model.username
        return cell
    }
}
