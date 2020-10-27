//
//  EssentialFeedAppTests.swift
//  EssentialFeedAppTests
//
//  Created by Arifin Firdaus on 27/10/20.
//

import XCTest
@testable import EssentialFeedApp


class RemoteFeedLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.get(from: URL(string: "https://a-url.com")!)
    }
}

protocol HTTPClient {
    func get(from url: URL) 
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        self.requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        // given
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client)
        
        // then
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_shouldRequestDataFromURL() {
        // given
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        // when
        sut.load()
        
        // then
        XCTAssertNotNil(client.requestedURL)
    }

}
