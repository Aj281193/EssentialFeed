//
//  FeedViewControllerTests+UIRefresh.swift
//  EssentialFeediOSTests
//
//  Created by Ashish Jaiswal on 27/02/23.
//

import XCTest

extension UIRefreshControl {
   func simulatePullToRefresh() {
       allTargets.forEach { target in
           actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
               (target as NSObject).perform(Selector($0))
           }
       }
   }
}
