//
//  UIView+Extension.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 28/06/23.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
