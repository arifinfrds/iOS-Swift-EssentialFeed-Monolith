//
//  RemoteFeedLoader.swift
//  EssentialFeedApp
//
//  Created by Arifin Firdaus on 27/10/20.
//

import Foundation

public class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(from: url)
    }
}

public protocol HTTPClient {
    func get(from url: URL)
}
