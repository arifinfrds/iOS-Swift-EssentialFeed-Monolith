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
        HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    private init() {}
    
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        // given
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        // then
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_shouldRequestDataFromURL() {
        // given
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        // when
        sut.load()
        
        // then
        XCTAssertNotNil(client.requestedURL)
    }

}
