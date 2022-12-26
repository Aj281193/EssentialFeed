//
//  XCTestCase+TrackMemoryLeak.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 18/12/22.
//

import XCTest

extension XCTestCase {
    
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have beeen deallocated, potential memory leak.",file: file, line: line)
        }
    }
}
