//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Ashish Jaiswal on 27/01/23.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {

    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut,loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading request before view is loaded")
  
       
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once the view is loaded")
  
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiate a load")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected a third loading request once user initiates another load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected a loading indicator once the view is loaded")
  
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once the loading completed successfully")
   
   
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected a loading indicator once the user initiates a reload")

        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user complete with an error")
        
    }
    
    func test_loadFeedCompletion_renderSuccessFullyLoadedFeed() {
        let image0 = makeImage(description: "any description",location: "any location")
        let image1 = makeImage(description: nil,location: "any location")
        let image2 = makeImage(description: "any description",location: nil)
        let image3 = makeImage(description: nil,location: nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendring: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendring: [image0])

        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0,image1,image2,image3],at: 1)
        assertThat(sut, isRendring: [image0,image1,image2,image3])
    }
    
    func test_loadFeedCompletion_doesNotAlterRenderStateOnError() {
        let image0 = makeImage()
        
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendring: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendring: [image0])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL request until view become visible")
        
        sut.simulatedFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once the first view is visible")
        
        sut.simulatedFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url,image1.url], "Expected second image URL request once the second view is visible")
    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnyMore() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        
        let (sut,loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no image URL request until view become visible")
        
        sut.simulatedFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first image URL request once the first view is not visible Anymore")
        
        sut.simulatedFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url,image1.url], "Expected second image URL request once the second view is not visible Anymore")
    }
    
    func test_feedImageViewloadingIndicator_isVisbleWhileLoadingImage() {
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulatedFeedImageViewVisible(at: 0)
        let view1 = sut.simulatedFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading the first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for Second view while loading the Second image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once the first image loading completed successully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once the first image loading complets successfully")
        
        loader.completedImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for the first view once the second image loading completed with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for second view once the second image loading completed with error")
    }
    
    func test_feedImageView_renderImageLoadedFromURL() {
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(),makeImage()])
        
        let view0 = sut.simulatedFeedImageViewVisible(at: 0)
        let view1 = sut.simulatedFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.renderImage, .none, "Expect no image for frist view while loading the first image")
        XCTAssertEqual(view1?.renderImage, .none, "Expect no image for second view while loading the second image")
        
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0 , at: 0)
        
        XCTAssertEqual(view0?.renderImage, imageData0, "Expected  image for first view once the first image loading completed succesfully")
        XCTAssertEqual(view1?.renderImage, .none , "Expected no image state change for second view once the first image loading completed successfully")
        
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1 ,at: 1)
        XCTAssertEqual(view0?.renderImage, imageData0, "Expected no image state change for first view once the second image loading completes successully")
        XCTAssertEqual(view1?.renderImage, imageData1," Expected image for second view once the seconf image loading completed successfully")
        
        
    }
    
    func test_feedImageviewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(),makeImage()])
        
        let view0 = sut.simulatedFeedImageViewVisible(at: 0)
        let view1 = sut.simulatedFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading the first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading the second image")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once the first image loading completed successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once the first image loading completes successfully")
        
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once the second image loading completes with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected  retry action for second view once the second image loading complete with Error")
        
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage()])
        
        let view = sut.simulatedFeedImageViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action while loading image")
        
        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, true, "expected retry action once image loading completes with invalid image data")
    }
    
    func test_feedImageViewRetryAction_retriesImageLoad() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        
        let (sut,loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0,image1])
        
        let view0 = sut.simulatedFeedImageViewVisible(at: 0)
        let view1 = sut.simulatedFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(loader.loadedImageURLs, [image0.url,image1.url], "Expected two image URL request for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url,image1.url], "Expected two image URL request before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url,image1.url,image0.url], "Expected 3rd imageURL request after first view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url,image1.url,image0.url, image1.url], "Expected 4th imageURL request after second view retry action")
        
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0,image1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulatedFeedImageViewVNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url],"Expected first image URL request once first image is near visble")
        
        sut.simulatedFeedImageViewVNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected Second image URL request once the second image is near visible")
        
    }
    
    func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0,image1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL request until  image is not near visible")
        
        sut.simulatedFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first cancelled image URL request once the frist image is not near visible anymore")
        
        sut.simulatedFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url,image1.url], "Expected second cancelled image URL request once the second image is not near visible anymore")
        
    }
    
    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage()])
        
        let view = sut.simulatedFeedImageViewNotVisible(at: 0)
        loader.completeImageLoading(with: anyImageData())
        
        XCTAssertNil(view?.renderImage , "Expected no rendered image when image load finishes after the view is not visible anymore")
    }
    
    //Mark:- Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedloader: loader, imageLoader: loader)
        trackForMemoryLeak(sut,file: file,line: line)
        trackForMemoryLeak(loader,file: file,line: line)
        return (sut,loader)
    }
    
    private func assertThat(_ sut: FeedViewController, isRendring feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.numbderOfRenderFeedImageView(), feed.count)
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasConfiguredFor: image, at: index)
        }
    }
    
    private func assertThat(_ sut: FeedViewController, hasConfiguredFor image: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file,line: line)
        }
    
        let shouldLocationVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationVisible, "Expected \(shouldLocationVisible) for image view at \(index)",file: file,line: line)
        
        XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image view at index \(index)",file: file,line: line)
        
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at \(index)",file: file,line: line)
    }
    
    private func anyImageData()  -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
       return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
      
        //MARK: FeedLoader
        private var feedRequests = [(FeedLoader.Result) -> Void]()
       
        var loadFeedCallCount: Int {
            return feedRequests.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index](.failure(error))
        }
        
        //MARK: ImageDataLoader
        
        var loadedImageURLs: [URL] {
            return imageRequest.map { $0.url }
        }
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallback: () -> Void
            
            func cancel() {
                cancelCallback()
            }
        }
        
        private var imageRequest = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        private(set) var cancelledImageURLs = [URL]()
        
      
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequest.append((url,completion))
            return TaskSpy { [weak self] in  self?.cancelledImageURLs.append(url)  }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequest[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError( at index: Int) {
            let error = NSError(domain: "any Error", code: 0)
            imageRequest[index].completion(.failure(error))
        }
        
        
        func completedImageLoadingWithError(at index: Int) {
            let error = NSError(domain: "any error", code: 0)
            imageRequest[index].completion(.failure(error))
        }
    }
}

private extension FeedViewController {
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulatedFeedImageViewVNearVisible(at index: Int) {
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: feedImageSection)
        ds?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulatedFeedImageViewNotNearVisible(at row: Int) {
        simulatedFeedImageViewVNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    
    func numbderOfRenderFeedImageView() -> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    
    @discardableResult
    func simulatedFeedImageViewVisible(at index: Int)  -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulatedFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulatedFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        return view
    }
    
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var feedImageSection: Int {
        return 0
    }
}

private extension FeedImageCell {
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
    
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var isShowingRetryAction: Bool {
        return !feedImageRetryButton.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var renderImage: Data? {
        return feedImageView.image?.pngData()
    }
}

private extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { renderContext in
            color.setFill()
            renderContext.fill(rect)
        }
    }
}
