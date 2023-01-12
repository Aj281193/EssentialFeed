//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 05/01/23.
//

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    
    func test_retrive_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetriveDeliversEmptyOnEmptyCache(sut)
    }
    
    func test_retrive_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetriveHasNoSideEffectsOnEmptyCache(sut)
    }
    
    func test_retrive_deliversFoundValueOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetriveDeliversFoundValueOnNonEmptyCache(sut)
    }
    
    func test_retrive_hasNoSideEffectOnNonEmptyCache() {
        let sut = makeSUT()
        
        asssertThatRetriveHasNoSideEffectsOnNonEmptyCache(sut)
    }
    
    func test_retrieve_deliversFailureOnRetrivalError() {
        let sut = makeSUT()
        
        try! "InvalidData".write(to: testSpecificStoreURL, atomically: false, encoding: .utf8)
        
        assertThatRetriveDeliversFailureOnRetrivalError(sut)
    }
    
    func test_retrieve_hasNoSideEffectOnFailure() {
        let sut = makeSUT()
        
        try! "InvalidData".write(to: testSpecificStoreURL, atomically: false, encoding: .utf8)
        
        assertThatRetriveHasNoSideEffectsOnfailure(sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnEmptyCache(sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnNonEmptyCache(sut)
    }
    
    func test_insert_overidesPreviouslyInsertedCacheValue() {
        let sut = makeSUT()
        
        assertThatInsertOveridesPreviouslyInsertedCacheValue(sut)
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
    
        assertThatInsertDeliversErrorOnInsertionError(sut)
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
    
        assertThatInsertHasNoSideEffectsOnInsertionError(sut)
        
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteDeliversNoErrorOnEmptyCache(sut)
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteHasNoSideEffectsOnEmptyCache(sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        assertThatDeleteEmptiesPreviouslyInsertedCache(sut)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDelePermissionURL = noDeletePermissionURL()
        let sut = makeSUT(storeURL: noDelePermissionURL)
        
        assertThatDeleteDeliversErrorOnDeletionError(sut)
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDelePermissionURL = noDeletePermissionURL()
        let sut = makeSUT(storeURL: noDelePermissionURL)
        
        assertThatDeleteHasNoSideEffectsOnDeletionError(sut)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        assertThatSideEffetsRunSerially(sut)
    }
    
    //MARK: Helpers
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL)
        trackForMemoryLeak(sut,file: file,line: line)
        return sut
    }
    
    
    var testSpecificStoreURL: URL {
        return cacheDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cacheDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func noDeletePermissionURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }
    
    private func  setupEmptyStoreState() {
        deleteStoreArtifact()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifact()
    }
    
    private func deleteStoreArtifact() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }
}
