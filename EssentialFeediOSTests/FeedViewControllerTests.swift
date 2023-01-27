//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Ashish Jaiswal on 27/01/23.
//

import XCTest
import EssentialFeed

final class FeedViewController: UIViewController {
    private var loader: FeedLoader?
    
     init(loader: FeedLoader) {
         self.loader = loader
         super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load() { _ in}
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let (_,loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_LoadsFeed() {
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }

    //Mark:- Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeak(sut,file: file,line: line)
        trackForMemoryLeak(loader,file: file,line: line)
        return (sut,loader)
    }
    
    class LoaderSpy: FeedLoader {
        private(set) var loadCallCount = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
}
