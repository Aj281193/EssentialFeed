//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 17/12/22.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    /// The completion Handler can be invoked in any thread.
    /// Client  are responsible to dispatch to appropriate thread if needed.
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
    
}

extension HTTPClient {
    func post(_ data: Data,to url: URL, completion: @escaping (HTTPClient.Result) -> Void) { }
}
