//
//  FeedSnapShotTests.swift
//  EssentialFeediOSTests
//
//  Created by Ashish Jaiswal on 17/06/23.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class FeedSnapShotTests: XCTestCase {

    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        record(snapshot: sut.snapshot(), name: "EMPTY_FEED")
    }

    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        record(snapshot: sut.snapshot(), name: "FEED_WITH_CONTENT")
    }
    
    func test_feedWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(message: "This is a\nmultiline\nerror message"))
        
        record(snapshot: sut.snapshot(), name: "FEED_WITH_ERROR_MESSAGE")
    }
    
    
    
    // MARK Helpers
    
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
    
    private func feedWithContent() -> [ImageStub] {
        return [
            ImageStub(
                    description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    location: "East Side Gallery\nMemorial in Berlin, Germany",
                    image: UIImage.make(withColor: .red)
                ),
                ImageStub(
                    description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                    location: "Garth Pier",
                    image: UIImage.make(withColor: .green)
                )
        ]
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

private class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel<UIImage>
    weak var controller: FeedImageCellController?
    
    init(description: String?, location: String?, image: UIImage?) {
      viewModel = FeedImageViewModel(description: description, location: location, image: image, isLoading: false, shouldRetry: image == nil)
    }
    func didRequestImage() {
        controller?.display(viewModel)
    }
    
    func didCancelImageRequest() { }
}
