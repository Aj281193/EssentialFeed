//
//  FeedViewController+Assertions.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 28/06/23.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegrationTests {
    
  func assertThat(_ sut: ListViewController, isRendring feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        XCTAssertEqual(sut.numbderOfRenderFeedImageView(), feed.count)
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasConfiguredFor: image, at: index)
        }
      executeRunLoopToCleanUpReferences()
    }
    
   func assertThat(_ sut: ListViewController, hasConfiguredFor image: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file,line: line)
        }
    
        let shouldLocationVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationVisible, "Expected \(shouldLocationVisible) for image view at \(index)",file: file,line: line)
        
        XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image view at index \(index)",file: file,line: line)
        
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at \(index)",file: file,line: line)
    }
    
    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
    }
}
