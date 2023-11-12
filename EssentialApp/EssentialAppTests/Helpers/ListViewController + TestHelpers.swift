//
//  ListViewController + TestHelpers.swift
//  EssentialAppTests
//
//  Created by Ashish Jaiswal on 11/11/23.
//

import UIKit
import EssentialFeediOS


extension ListViewController {
    
    func simulateAppearance() {
        if !isViewLoaded {
            prepareForFirstAppearance()
        }
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    private func prepareForFirstAppearance() {
        setSmallFrameToPreventRenderingCells()
        
        replaceRefreshControlWithFakeForiOS17Support()
    }
    
    private func setSmallFrameToPreventRenderingCells() {
        tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
    }
    
    func replaceRefreshControlWithFakeForiOS17Support() {
        let fakeRereshControl = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fakeRereshControl.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        refreshControl = fakeRereshControl
    }
}
private class FakeRefreshControl: UIRefreshControl {
    private var _isRefreshing = false
   
    override var isRefreshing: Bool { _isRefreshing }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}
