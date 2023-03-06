//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 06/03/23.
//

import UIKit


public final class ErrorView: UIView {
    
    @IBOutlet private weak var label: UILabel!
    
    public var message: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }
}
