//
//  URLSessionHttpClientTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 17/12/22.
//

import XCTest
import EssentialFeed

class URLSessionHttpClientTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        URLProtocolStub.removeStub()
    }
    
    func test_getFromURL_performGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_performPostRequestWith_DataAndURL() {
        let url = anyURL()
        let data = anyData()
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.httpBodyData, data)
            exp.fulfill()
        }
        
        makeSUT().post(data, to: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    }
    
    
    func test_getFromURL_failsOnRequestError() {
        
        let requestError = anyError()
        
        let receivedError = resultErrorFor((data: nil, response: nil, error: requestError))
        
        XCTAssertEqual((receivedError as NSError?)?.domain , requestError.domain)
        
    }

    func test_getFromURL_failsOnAllInvalidRepresentableTestCases() {
        
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response:nonHTTPURLResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
    }
    
    func test_getFromURL_succeedOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let receivedValue = resultValuesFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(receivedValue?.data, data)
        XCTAssertEqual(receivedValue?.response.url, response.url)
        XCTAssertEqual(receivedValue?.response.statusCode, response.statusCode)
        
    }
    
    func test_getFromURL_succeedWithEmptyDataOnHttpURLResponseWithNilData() {
       let response = anyHTTPURLResponse()

        let receivedValue = resultValuesFor(data: nil, response: response, error: nil)
        
        
        let emptyData = Data()
        XCTAssertEqual(receivedValue?.data, emptyData)
        XCTAssertEqual(receivedValue?.response.url, self.anyHTTPURLResponse().url)
        XCTAssertEqual(receivedValue?.response.statusCode, self.anyHTTPURLResponse().statusCode)
        
    }
    
    func test_cancelGetFromURLTask_cancelURLRequest() {
        let receivedError = resultErrorFor(taskHandler: {$0.cancel()}) as NSError?
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    
   // MARK:- Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHttpClient(session: session)
        trackForMemoryLeak(sut,file: file,line: line)
        return sut
    }
 
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data,response: HTTPURLResponse)? {
        
        let result = resultFor((data: data, response: response, error: error),file: file,line: line)
        
        switch result {
        case let .success((data, response)):
            return (data,response)
        default:
            XCTFail("Expected failure got \(result) instead", file: file,line: line)
            return nil
        }
        
    }
    
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #file, line: UInt = #line) -> Error?  {
        
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure got \(result) instead", file: file,line: line)
        }
        return nil
    }
    
    
    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result {
        values.map {
            URLProtocolStub.stub(
                data: $0,
                response: $1,
                error: $2)
        }
        let sut = makeSUT(file: file,line: line)
        let exp = expectation(description: "wait for expectation")
        
        var receivedResult: HTTPClient.Result!
        taskHandler(
            sut.get(from: anyURL()) { result in
            receivedResult = result
             exp.fulfill()
         })
        
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
}
