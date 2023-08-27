//
//  LoadMoreCellController.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 26/08/23.
//

import UIKit
import EssentialFeed

public final class LoadMoreCellController: NSObject, UITableViewDataSource {
    private let cell = LoadMoreCell()
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell
    }
}

extension LoadMoreCellController: ResourceLoadingView, ResourceErrorView {
    public func display(_ viewModel: EssentialFeed.ResourceErrorViewModel) {
        cell.message = viewModel.message
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell.isLoading = viewModel.isLoading
    }
}
