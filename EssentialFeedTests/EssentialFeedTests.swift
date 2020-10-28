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
        sut.load()
        
        // then
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_shouldRequestsDataFromURLTwice() {
        // given
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        // when
        sut.load()
        sut.load()
        
        // then
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        // given
        let (sut, client) = makeSUT()
        var capturedErrors: [RemoteFeedLoader.Error] = []
        
        // when
        sut.load { error in
            capturedErrors.append(error)
        }
        let clientError = NSError(domain: "error", code: 1, userInfo: nil)
        client.complete(with: clientError)
        
        // then
        XCTAssertEqual(capturedErrors, [.connectivity])
        
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] = []
        var completions: [(Error?) -> Void] = []
  
        func get(from url: URL, completion: @escaping (Error?) -> Void) {
            self.requestedURLs.append(url)
            completions.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](error)
        }
        
    }
    
}

