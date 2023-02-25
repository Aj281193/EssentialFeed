//
//  UITableView+dequeuing.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 26/02/23.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
    
}
