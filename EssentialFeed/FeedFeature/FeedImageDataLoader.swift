//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 07/02/23.
//

import Foundation

public  protocol FeedImageDataLoader: AnyObject {
    
    func loadImageData(from url: URL) throws -> Data
}
