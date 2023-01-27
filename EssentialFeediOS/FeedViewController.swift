//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 27/01/23.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    
    public init(loader: FeedLoader) {
         self.loader = loader
         super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}
