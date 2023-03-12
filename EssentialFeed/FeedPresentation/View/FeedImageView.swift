//
//  FeedImageView.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 11/03/23.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image
    
    func display(_ model: FeedImageViewModel<Image>)
}
