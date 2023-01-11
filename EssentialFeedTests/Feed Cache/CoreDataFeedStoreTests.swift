//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 11/01/23.
//

import XCTest
import EssentialFeed

final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
    func test_retrive_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetriveDeliversEmptyOnEmptyCache(sut)
    }
    
    func test_retrive_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetriveHasNoSideEffectsOnEmptyCache(sut)
    }
    
    func test_retrive_deliversFoundValueOnNonEmptyCache() {
        
    }
    
    func test_retrive_hasNoSideEffectOnNonEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_insert_overidesPreviouslyInsertedCacheValue() {
        
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_storeSideEffects_runSerially() {
        
    }
    
    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let sut = try! CoreDataFeedStore(bundle: storeBundle)
        trackForMemoryLeak(sut,file: file,line: line)
        return sut
    }
}
