//
//  ImageCommentsCellController.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 05/08/23.
//

import UIKit
import EssentialFeed

public final class ImageCommentsCellController: NSObject, CellController {
  
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
  
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.dateLabel.text = model.date
        cell.usernameLabel.text = model.username
        return cell
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {}
}
