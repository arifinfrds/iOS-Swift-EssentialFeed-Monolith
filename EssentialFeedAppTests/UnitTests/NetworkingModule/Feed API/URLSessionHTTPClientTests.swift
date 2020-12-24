//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedAppTests
//
//  Created by Arifin Firdaus on 11/11/20.
//

import XCTest
@testable import EssentialFeedApp

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = makeAnyURL()
        
        let exp = expectation(description: "wait for request")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        // given
        let requestError = NSError(domain: "any error", code: 1)
        
        // when
        let receivedError = resultForError(data: nil, response: nil, error: requestError) as NSError?
        
        // then
        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultForError(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultForError(data: nil, response: makeNonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultForError(data: makeAnyData(), response: nil, error: nil))
        XCTAssertNotNil(resultForError(data: makeAnyData(), response: nil, error: makeAnyNSError()))
        XCTAssertNotNil(resultForError(data: nil, response: makeNonHTTPURLResponse(), error: makeAnyNSError()))
        XCTAssertNotNil(resultForError(data: nil, response: makeAnyHTTPURLResponse(), error: makeAnyNSError()))
        XCTAssertNotNil(resultForError(data: makeAnyData(), response: makeNonHTTPURLResponse(), error: makeAnyNSError()))
        XCTAssertNotNil(resultForError(data: makeAnyData(), response: makeAnyHTTPURLResponse(), error: makeAnyNSError()))
        XCTAssertNotNil(resultForError(data: makeAnyData(), response: makeNonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_succedsOnHTTPURLResponseWithData() {
        // given
        let givenData = makeAnyData()
        let givenHTTPURLResponse = makeAnyHTTPURLResponse()
        
        // when
        let receivedValues = resultValuesFor(data: givenData, response: givenHTTPURLResponse, error: nil)
        
        // then
        XCTAssertEqual(receivedValues?.data, givenData)
        XCTAssertEqual(receivedValues?.response.url, givenHTTPURLResponse.url)
        XCTAssertEqual(receivedValues?.response.statusCode, givenHTTPURLResponse.statusCode)
    }
    
    func test_getFromURL_succedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        // given
        let givenHTTPURLResponse = makeAnyHTTPURLResponse()
        
        // when
        let receivedValues = resultValuesFor(data: nil, response: givenHTTPURLResponse, error: nil)
        
        // then
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, givenHTTPURLResponse.url)
        XCTAssertEqual(receivedValues?.response.statusCode, givenHTTPURLResponse.statusCode)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(for: sut, file: file, line: line)
        return sut
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error)
        
        switch result {
        case let .success(data, response):
            return (data, response)
        case let .failure(error):
            XCTFail("Expected success, but got failure instead with error: \(error)")
            return nil
        }
    }
    
    private func resultForError(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        // when
        switch result {
        case .failure(let error):
            return error
        default:
            XCTFail("Expected failure with error: \(String(describing: error)), but got result: \(result)", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "wait for completion")
        var capturedResult: HTTPClientResult!
        makeSUT().get(from: makeAnyURL()) { result in
            capturedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return capturedResult
    }
    
    private func makeAnyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func makeAnyData() -> Data {
        return "any data".data(using: .utf8)!
    }
    
    private func makeNonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: makeAnyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func makeAnyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: makeAnyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func makeAnyNSError() -> NSError {
        return NSError(domain: "Any error", code: 0)
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
        
    }
    
}
