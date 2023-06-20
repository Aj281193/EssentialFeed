//
//  FeedSnapShotTests.swift
//  EssentialFeediOSTests
//
//  Created by Ashish Jaiswal on 19/06/23.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class FeedSnapShotTests: XCTestCase {
    
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), name: "EMPTY_FEED_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), name: "EMPTY_FEED_DARK")

    }
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), name: "FEED_WITH_CONTENT_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), name: "FEED_WITH_CONTENT_DARK")

    }
    
    func test_feed_WithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(message: "This is \nmultiline\n error"))
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), name: "FEED_WITH_ERROR_MESSAGE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), name: "FEED_WITH_ERROR_MESSAGE_DARK")

        
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        sut.display(feedWithFailedImageLoading())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), name: "FEED_WITH_FAILED_IMAGE_LOADING_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), name: "FEED_WITH_FAILED_IMAGE_LOADING_DARK")

    }
    
    //MARK Helpers:-
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsHorizontalScrollIndicator = false
        controller.tableView.showsVerticalScrollIndicator = false
        return controller
    }
    
    private func feedWithFailedImageLoading() -> [ImageStub] {
        return [
            ImageStub(description: nil, location: "Common Street London", image: nil),
            ImageStub(description: nil, location: "Brighton Seafront", image: nil)
            ]
    }
    
    private func feedWithContent() -> [ImageStub] {
        return [
            ImageStub(description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                      location: "East Side Gallery\nMemorial in Berlin, Germany",
                      image: UIImage.make(withColor: .red)
                ),
                ImageStub(description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                    location: "Garth Pier",
                    image: UIImage.make(withColor: .green)
                )

        ]
    }
    private func emptyFeed() -> [FeedImageCellController] {
        return []
    }
    
    private func record(snapshot: UIImage, name: String, file: StaticString = #file, line: UInt = #line) {
        let snapShotData = makeSnapshotData(for: snapshot)
        
        //EssentialFeediOSTests/snapshots/EMPTY_FEED.png
        let snapshotURL = makeSnapShotURL(name: name)
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            
            // saving our snapshotData
            try snapShotData?.write(to: snapshotURL)
        } catch {
           XCTFail("Failed to record snapshot with error: \(error)",file: file,line: line)
        }
    }
    
    private func assert(snapshot: UIImage, name: String, file: StaticString = #file, line: UInt = #line) {
        let snapShotData = makeSnapshotData(for: snapshot)
        
        //EssentialFeediOSTests/snapshots/EMPTY_FEED.png
        let snapshotURL = makeSnapShotURL(name: name)
        
        guard let storedSnapShot = try? Data(contentsOf: snapshotURL) else {
            XCTFail("failed to load stored snapshot at URL: \(snapshotURL). Use the 'record' method to store snapshot before asserting.",file: file,line: line)
            return
        }
        
        if snapShotData != storedSnapShot {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(),isDirectory: true).appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapShotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot doesn't match stored snapshot. New snapshot URL:\(temporarySnapshotURL), stored snapshot URL: \(snapshotURL)",file: file,line: line)

        }
        
    }
    
    private func makeSnapshotData(for snapshot: UIImage, file: StaticString = #file, line: UInt = #line) -> Data? {
        guard let snapShotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot",file: file,line: line)
            return nil
        }
        return snapShotData
    }
    
    private func makeSnapShotURL(name: String, file: StaticString = #file, line: UInt = #line) -> URL {
        return URL(fileURLWithPath: String(describing: file)).deletingLastPathComponent().appendingPathComponent("snapshots").appendingPathComponent("\(name).png")
    }

}
    
private extension FeedViewController {
    func display(_ stub: [ImageStub]) {
        let cells: [FeedImageCellController] = stub.map { stub in
            let cellController = FeedImageCellController(delegate: stub)
            stub.controller = cellController
            return cellController
        }
        display(cells)
    }
}
private  class ImageStub: FeedImageCellControllerDelegate {
    
    private let viewModel: FeedImageViewModel<UIImage>
    weak var controller: FeedImageCellController?
    
    init(description: String?, location: String?, image: UIImage?) {
        self.viewModel = FeedImageViewModel(description: description, location: location, image: image, isLoading: false, shouldRetry: image == nil)
    }
    func didRequestImage() {
        controller?.display(viewModel)
    }
    
    func didCancelImageRequest() { }
    
}
