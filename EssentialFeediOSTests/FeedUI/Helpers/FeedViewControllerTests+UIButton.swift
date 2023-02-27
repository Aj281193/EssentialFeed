//
//  FeedViewControllerTests+UIButton.swift
//  EssentialFeediOSTests
//
//  Created by Ashish Jaiswal on 27/02/23.
//

import XCTest

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
