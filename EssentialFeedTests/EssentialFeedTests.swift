//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Arifin Firdaus on 27/10/20.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        // given
        let (_, client) = makeSUT()
        
        // then
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_shouldRequestsDataFromURL() {
        // given
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        // when
        sut.load { _ in }
        
        // then
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_shouldRequestsDataFromURLTwice() {
        // given
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        // when
        sut.load { _ in }
        sut.load { _ in }
        
        // then
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        // given
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .connectivity, when: {
            let clientError = NSError(domain: "error", code: 1, userInfo: nil)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        // given
        let (sut, client) = makeSUT()
        var capturedErrors: [RemoteFeedLoader.Error] = []
        
        let codes = [199, 201, 300, 400, 500]
        for (index, code) in codes.enumerated() {
            expect(sut, toCompleteWithError: .invalidData, when: {
                client.complete(withStatusCode: code, at: index)
                capturedErrors.removeAll()
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSONData() {
        // given
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .invalidData, when: {
            let invalidJSON = Data("invalid-json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWithError error: RemoteFeedLoader.Error,
        when action: (() -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var capturedResults: [RemoteFeedLoader.Result] = []
        sut.load { result in
            capturedResults.append(result)
        }
        action()
        
        XCTAssertEqual(
            capturedResults,
            [RemoteFeedLoader.Result.failure(error)],
            file: file,
            line: line
        )
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL, completion: (HTTPClientResult) -> Void)] = []
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(
            from url: URL,
            completion: @escaping (HTTPClientResult) -> Void
        ) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
        
    }
    
}


