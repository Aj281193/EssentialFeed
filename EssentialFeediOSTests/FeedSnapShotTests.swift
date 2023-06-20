//
//  FeedSnapShotTests.swift
//  EssentialFeediOSTests
//
//  Created by Ashish Jaiswal on 19/06/23.
//

import XCTest
import EssentialFeediOS

final class FeedSnapShotTests: XCTestCase {
    
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        record(snapshot: sut.snapshot(), name: "EMPTY_FEED")
    }
    
    //MARK Helpers:-
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        return []
    }
    
    private func record(snapshot: UIImage, name: String, file: StaticString = #file, line: UInt = #line) {
        guard let snapShotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot",file: file,line: line)
            return
        }
        
        //EssentialFeediOSTests/snapshots/EMPTY_FEED.png
        let snapshotURL = URL(fileURLWithPath: String(describing: file)).deletingLastPathComponent().appendingPathComponent("snapshots").appendingPathComponent("\(name).png")
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            
            // saving our snapshotData
            try snapShotData.write(to: snapshotURL)
        } catch {
           XCTFail("Failed to record snapshot with error: \(error)",file: file,line: line)
        }
    }

}
extension UIViewController {
    func snapshot() -> UIImage {
        let rendered = UIGraphicsImageRenderer(bounds: view.bounds)
        return rendered.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}
