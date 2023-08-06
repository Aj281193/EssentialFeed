//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 27/01/23.
//

import UIKit
import EssentialFeed

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
  
    @IBOutlet var refreshController: UIRefreshControl?
    
    public var onRefresh: (() -> Void)?
    
    private var loadingControllers = [IndexPath: CellController]()
    
    @IBOutlet private(set) public var errorView: ErrorView?
    
    private var tableModel = [CellController]() {
        didSet {
            tableView.reloadData()
        }
    }
     
    public override func viewDidLoad() {
        super.viewDidLoad()

        refresh()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.sizeTableHeaderToFit()
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView?.message = viewModel.message
    }
    
    public func display(_ cellController: [CellController]) {
        loadingControllers = [:]
        tableModel = cellController
    }
    
    @IBAction func refresh() {
        onRefresh?()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ds = cellController(forRowAt: indexPath).dataSource
        return ds.tableView(tableView, cellForRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = removeLoadingConttroller(forRowAt: indexPath)?.delegate
       dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(forRowAt: indexPath).dataSourcePrefecting
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> CellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = removeLoadingConttroller(forRowAt: indexPath)?.dataSourcePrefecting
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func removeLoadingConttroller(forRowAt indexPath: IndexPath) -> CellController? {
        let controller = loadingControllers[indexPath]
        loadingControllers[indexPath] = nil
        return controller
    }
    
}

