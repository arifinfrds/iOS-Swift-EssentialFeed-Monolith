//
//  EssentialFeedAppTests.swift
//  EssentialFeedAppTests
//
//  Created by Arifin Firdaus on 27/10/20.
//

import XCTest
@testable import EssentialFeedApp


class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()
    
    func get(from url: URL) { }
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    override func get(from url: URL) {
        self.requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        // given
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()
        
        // then
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_shouldRequestDataFromURL() {
        // given
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        // when
        sut.load()
        
        // then
        XCTAssertNotNil(client.requestedURL)
    }

}
