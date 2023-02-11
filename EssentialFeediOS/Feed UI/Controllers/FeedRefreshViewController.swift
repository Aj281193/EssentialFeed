//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 07/02/23.
//

import UIKit

final class FeedRefreshViewController: NSObject {
    
    private(set) lazy var view: UIRefreshControl =  binded(UIRefreshControl())
    
    var viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingSateChange = { [weak view] isLoading in
            if isLoading {
               view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
