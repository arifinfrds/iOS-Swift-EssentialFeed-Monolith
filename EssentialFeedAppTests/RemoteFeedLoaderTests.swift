//
//  EssentialFeedAppTests.swift
//  EssentialFeedAppTests
//
//  Created by Arifin Firdaus on 27/10/20.
//

import XCTest
@testable import EssentialFeedApp


class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        // given
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        // then
        XCTAssertNil(client.requestedURL)
    }

}
