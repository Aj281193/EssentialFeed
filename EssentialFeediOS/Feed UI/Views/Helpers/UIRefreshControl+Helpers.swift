//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 06/03/23.
//

import UIKit

extension UIRefreshControl {
    
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
    
}
