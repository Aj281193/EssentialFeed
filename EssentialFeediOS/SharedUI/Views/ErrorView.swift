//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 06/03/23.
//

import UIKit


public final class ErrorView: UIButton {
        
    public var onHide: (() -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private var titleAttributes: AttributeContainer {
        let paragraphstyle = NSMutableParagraphStyle()
        paragraphstyle.alignment = .center
        
        var attributes = AttributeContainer()
        attributes.paragraphStyle = paragraphstyle
        attributes.font = UIFont.preferredFont(forTextStyle: .body)
        return attributes
    }
    
    private func hideMessage() {
        alpha = 0
        configuration?.attributedTitle = nil
        
        configuration?.contentInsets = .zero
        onHide?()
    }
    
    private func configure() {
        var configuration = Configuration.plain()
        configuration.titlePadding = 0
        configuration.baseForegroundColor = .white
        configuration.background.backgroundColor = .errorBackgroundColor
        configuration.background.cornerRadius = 0
        self.configuration = configuration
        
        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
    
        hideMessage()
    }
    
    public var message: String? {
        get {
            return isVisible ? configuration?.title : nil
        }
        set {
           setMessageAnimated(newValue)
        }
    }
    
    public var isVisible: Bool {
        return alpha > 0
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message = message {
           showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }
    
   
    
    private func showAnimated(_ message: String) {
        configuration?.attributedTitle = AttributedString(message, attributes: titleAttributes)
        
        configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    @IBAction private func hideMessageAnimated() {
        UIView.animate(withDuration: 0.25,  animations: { self.alpha = 0}) { completed in
            if completed { self.hideMessage() }
        }
    }
}

extension UIColor {
   static var errorBackgroundColor: UIColor {
        UIColor(red: 1, green: 0.41568627450000001, blue: 0.41568627450000001, alpha: 1)
    }
}
